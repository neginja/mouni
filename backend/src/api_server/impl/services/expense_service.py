import math

from api_server.impl.errors import ForbiddenError, NotFoundError, ValidationError
from api_server.impl.persistence.expense_involved_repository import (
    ExpenseInvolvedRepository,
)
from api_server.impl.persistence.expense_repository import ExpenseRepository
from api_server.impl.persistence.settlement_repository import SettlementRepository
from api_server.impl.utils import logger_from_env
from api_server.models.expense import Expense

logger = logger_from_env("ExpenseService")


class ExpenseService:
    def __init__(
        self,
        expense_repo: ExpenseRepository,
        expense_involved_repo: ExpenseInvolvedRepository,
        settlement_repo: SettlementRepository,
    ) -> None:
        self.expense_repo = expense_repo
        self.expense_involved_repo = expense_involved_repo
        self.settlement_repo = settlement_repo
        logger.debug("ExpenseService initialized")

    async def _check_paid_settlements_exist(self, activity_id: str):
        """Raise ForbiddenError if any settlements exist for the activity."""
        settlements = self.settlement_repo.list_by_activity(activity_id)
        if any(s.paid for s in settlements):
            raise ForbiddenError(
                "Cannot add or modify expenses because activity has paid settlements"
            )

    async def create_expense(
        self, expense: Expense, activity_id: str, equal_split: bool = True
    ) -> Expense:
        await self._check_paid_settlements_exist(activity_id)
        logger.info(
            f"Creating expense for activity_id={activity_id}, expense={expense}"
        )

        if not expense.amount or expense.amount < 0:
            raise ValidationError("Expense amount must be positive")

        if not expense.involved or len(expense.involved) == 0:
            raise ValidationError("At least one involved member must be provided")

        if equal_split:
            split_amount = expense.amount / len(expense.involved)
            computed_shares = [
                (inv.member_id, split_amount) for inv in expense.involved
            ]
            logger.debug(f"Equal split enabled, amount={split_amount}")
        else:
            total = sum(inv.share for inv in expense.involved)
            if not math.isclose(total, expense.amount, rel_tol=1e-6):
                raise ValidationError(
                    f"Sum of shares ({total}) does not equal expense amount ({expense.amount})"
                )
            computed_shares = [(inv.member_id, inv.share) for inv in expense.involved]
            logger.debug(f"Custom shares provided, shares={computed_shares}")

        saved_expense = self.expense_repo.create(
            activity_id=activity_id, expense=expense
        )
        logger.info(f"Expense created with id={saved_expense.id}")

        for member_id, share in computed_shares:
            self.expense_involved_repo.add_involved(
                member_id=member_id, expense_id=saved_expense.id, share=share
            )
            logger.debug(f"Added involved member {member_id} with share {share}")

        logger.debug("Clearing any existing unpaid settlements")
        self.settlement_repo.delete_all_for_activity(activity_id=activity_id)

        return saved_expense

    async def get_expense(self, activity_id: str, expense_id: str) -> Expense | None:
        logger.info(f"Fetching expense with id={expense_id}")
        expense = self.expense_repo.get(activity_id=activity_id, expense_id=expense_id)
        if expense:
            logger.debug(f"Found expense: {expense}")
            return expense
        else:
            logger.warning(f"Expense id={expense_id} not found")
            raise NotFoundError("Expense not found")
        return expense

    async def list_expenses(self, activity_id: str) -> list[Expense]:
        logger.info(f"Listing expenses for activity {activity_id}")
        expenses = self.expense_repo.list_by_activity(activity_id=activity_id)
        logger.debug(f"Found {len(expenses)} expenses")
        return expenses

    async def update_expense(
        self,
        activity_id: str,
        expense_id: str,
        expense: Expense,
        equal_split: bool = True,
    ) -> Expense | None:
        logger.info(f"Updating expense id={expense_id}, expense={expense}")
        # Fetch the existing expense to get activity_id
        existing = self.expense_repo.get(activity_id=activity_id, expense_id=expense_id)
        if not existing:
            raise ValidationError(f"Expense {expense_id} not found")

        await self._check_paid_settlements_exist(activity_id=activity_id)

        if expense.involved and len(expense.involved) > 0:
            if equal_split:
                split_amount = expense.amount / len(expense.involved)
                if split_amount < 0:
                    raise ValidationError("Split amount cannot be negative")
                logger.debug(
                    f"Equal split enabled. Split amount per member: {split_amount:.2f}"
                )
            else:
                total = sum(inv.share for inv in expense.involved)
                if not math.isclose(total, expense.amount, rel_tol=1e-6):
                    raise ValidationError(
                        f"Sum of shares ({total:.2f}) does not equal expense amount ({expense.amount:.2f})"
                    )
                if any(inv.share < 0 for inv in expense.involved):
                    raise ValidationError("Shares must be non-negative")
                logger.debug(
                    f"Custom shares validated, shares={[inv.share for inv in expense.involved]}"
                )

        updated_expense = self.expense_repo.update(
            activity_id=activity_id, expense_id=expense_id, expense=expense
        )
        if not updated_expense:
            logger.warning(f"Expense id={expense_id} not found for update")
            raise NotFoundError("Expense not found")

        self.expense_involved_repo.remove_all_by_expense(expense_id=expense_id)
        logger.debug(f"Removed existing involved members for expense {expense_id}")

        involved = []
        if expense.involved and len(expense.involved) > 0:
            if equal_split:
                split_amount = expense.amount / len(expense.involved)
                for inv in expense.involved:
                    inv_model = self.expense_involved_repo.add_involved(
                        member_id=inv.member_id,
                        expense_id=expense_id,
                        share=split_amount,
                    )
                    involved.append(inv_model)
                    logger.debug(
                        f"Added involved member_id={inv.member_id} with split amount={split_amount:.2f}"
                    )
            else:
                for inv in expense.involved:
                    inv_model = self.expense_involved_repo.add_involved(
                        member_id=inv.member_id, expense_id=expense_id, share=inv.share
                    )
                    involved.append(inv_model)
                    logger.debug(
                        f"Added involved member_id={inv.member_id} with share={inv.share:.2f}"
                    )

        updated_expense.involved = involved

        logger.debug("Clearing any existing unpaid settlements")
        self.settlement_repo.delete_all_for_activity(activity_id=activity_id)

        return updated_expense

    async def delete_expense(self, activity_id, expense_id: str) -> None:
        logger.info(f"Deleting expense with id={expense_id}")
        # Fetch the existing expense to get activity_id
        expense = self.expense_repo.get(activity_id=activity_id, expense_id=expense_id)
        await self._check_paid_settlements_exist(activity_id=activity_id)

        self.expense_repo.delete(activity_id=activity_id, expense_id=expense.id)
        self.expense_involved_repo.remove_all_by_expense(expense_id=expense.id)
        logger.info(f"Deleted expense and its involved members: {expense.id}")
