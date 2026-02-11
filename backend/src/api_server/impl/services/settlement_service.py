from collections import defaultdict

from api_server.impl.errors import ForbiddenError, NotFoundError, ValidationError
from api_server.impl.persistence.expense_repository import ExpenseRepository
from api_server.impl.persistence.settlement_repository import SettlementRepository
from api_server.impl.utils import logger_from_env
from api_server.models.expense import Expense
from api_server.models.settlement import Settlement

logger = logger_from_env("SettlementService")


class SettlementService:
    def __init__(
        self, settlement_repo: SettlementRepository, expense_repo: ExpenseRepository
    ) -> None:
        self.settlement_repo = settlement_repo
        self.expense_repo = expense_repo
        logger.debug("SettlementService initialized with repos")

    async def list_settlements(self, activity_id: str) -> list[Settlement]:
        logger.info(f"Listing settlements for activity_id={activity_id}")
        return self.settlement_repo.list_by_activity(activity_id=activity_id)

    async def create_settlement(
        self, settlement: Settlement, activity_id: str
    ) -> Settlement:
        logger.info(
            f"Creating settlement for activity_id={activity_id}, settlement={settlement}"
        )

        existing = self.settlement_repo.list_by_activity(activity_id=activity_id)
        if any(s.paid for s in existing):
            raise ForbiddenError(
                "Cannot create new settlement because one is already paid"
            )

        if settlement.from_member == settlement.to_member:
            raise ValidationError("debitor and creditor must be different")
        if settlement.amount <= 0:
            raise ValidationError("Settlement amount must be greater than zero")

        created = self.settlement_repo.create(
            settlement=settlement, activity_id=activity_id
        )
        logger.info(f"Settlement created with id={created.id}")
        return created

    async def get_settlement(self, activity_id: str, settlement_id: str) -> Settlement:
        logger.info(f"Fetching settlement id={settlement_id}")
        settlement = self.settlement_repo.get(
            activity_id=activity_id, settlement_id=settlement_id
        )
        if not settlement:
            logger.warning(f"Settlement not found id={settlement_id}")
            raise NotFoundError("Settlement not found")
        return settlement

    async def update_paid_status(
        self, activity_id: str, settlement_id: str, paid: bool
    ) -> Settlement:
        logger.info(f"Updating settlement id={settlement_id}, paid={paid}")
        existing = self.settlement_repo.get(
            activity_id=activity_id, settlement_id=settlement_id
        )
        if not existing:
            raise NotFoundError("Settlement not found")
        if existing.paid and paid is False:
            raise ForbiddenError(
                "Cannot unpay a settlement that is already marked as paid"
            )

        updated = self.settlement_repo.patch_paid_status(
            activity_id=activity_id, settlement_id=settlement_id, paid=paid
        )
        logger.info(f"Settlement updated: {settlement_id}")
        return updated

    async def delete_settlement(self, activity_id: str, settlement_id: str) -> None:
        logger.info(f"Deleting settlement id={settlement_id}")
        existing = self.settlement_repo.get(
            activity_id=activity_id, settlement_id=settlement_id
        )
        if not existing:
            raise NotFoundError("Settlement not found")

        existing = self.settlement_repo.list_by_activity(activity_id)
        if any(s.paid for s in existing):
            raise ForbiddenError(
                "Cannot delete settlements because one is already paid"
            )

        self.settlement_repo.delete(
            activity_id=activity_id, settlement_id=settlement_id
        )
        logger.info(f"Settlement deleted id={settlement_id}")

    async def clear_settlements(self, group_id: str, activity_id: str) -> None:
        logger.info(
            f"Clearing all settlements for activity_id={activity_id} in group_id={group_id}"
        )

        settlements = self.settlement_repo.list_by_activity(activity_id=activity_id)

        if not settlements:
            raise NotFoundError("No settlements found for this activity")

        if any(s.paid for s in settlements):
            raise ForbiddenError(
                "Cannot clear settlements because one or more are already paid"
            )

        self.settlement_repo.delete_all_for_activity(activity_id=activity_id)
        logger.info(
            f"All settlements cleared for activity_id={activity_id} in group_id={group_id}"
        )

    async def compute_current_settlement(self, activity_id: str) -> list[Settlement]:
        logger.info(f"Computing current settlements for activity_id={activity_id}")
        expenses: list[Expense] = self.expense_repo.list_by_activity(
            activity_id=activity_id
        )
        if not expenses:
            logger.info(f"No expenses found for activity {activity_id}")
            return []

        expenses_by_currency: dict[str, list[Expense]] = defaultdict(list)
        for exp in expenses:
            expenses_by_currency[exp.currency].append(exp)

        all_settlements: list[Settlement] = []
        for currency, expenses_for_currency in expenses_by_currency.items():
            balances: dict[str, float] = {}
            for exp in expenses_for_currency:
                balances[exp.paid_by] = balances.get(exp.paid_by, 0) + exp.amount
                for inv in exp.involved:
                    balances[inv.member_id] = balances.get(inv.member_id, 0) - inv.share

            creditors = [(m, bal) for m, bal in balances.items() if bal > 0]
            debtors = [(m, -bal) for m, bal in balances.items() if bal < 0]

            creditors.sort(key=lambda x: x[1], reverse=True)
            debtors.sort(key=lambda x: x[1], reverse=True)

            i, j = 0, 0
            while i < len(debtors) and j < len(creditors):
                from_member_id, debt_amt = debtors[i]
                to_member_id, cred_amt = creditors[j]
                settled_amt = min(debt_amt, cred_amt)

                all_settlements.append(
                    Settlement(
                        fromMember=from_member_id,
                        toMember=to_member_id,
                        amount=settled_amt,
                        currency=currency,
                    )
                )
                debt_amt -= settled_amt
                cred_amt -= settled_amt
                if debt_amt == 0:
                    i += 1
                else:
                    debtors[i] = (from_member_id, debt_amt)
                if cred_amt == 0:
                    j += 1
                else:
                    creditors[j] = (to_member_id, cred_amt)

        logger.info(f"Computed settlements={len(all_settlements)}")
        return all_settlements

    async def settle_activity(self, activity_id: str) -> list[Settlement]:
        logger.info(f"Settling activity id={activity_id}")

        existing_settlements = self.settlement_repo.list_by_activity(
            activity_id=activity_id
        )
        if any(s.paid for s in existing_settlements):
            raise ForbiddenError(
                "Cannot settle activity because one or more current settlements are already paid"
            )

        for s in existing_settlements:
            logger.debug(f"Deleting existing settlement id={s.id} before recomputing")
            self.settlement_repo.delete(activity_id=activity_id, settlement_id=s.id)

        settlements = await self.compute_current_settlement(activity_id=activity_id)

        created_settlements = []
        for settlement in settlements:
            s = await self.create_settlement(
                activity_id=activity_id, settlement=settlement
            )
            created_settlements.append(s)

        logger.info(
            f"Total settlements created for activity_id={activity_id}, count={len(created_settlements)}"
        )
        return created_settlements
