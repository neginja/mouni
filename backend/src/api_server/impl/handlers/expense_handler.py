from fastapi import Response, status

from api_server.apis.expenses_api_base import BaseExpensesApi
from api_server.impl.dependencies import get_expense_service
from api_server.models.expense import Expense
from api_server.models.expense_create import ExpenseCreate
from api_server.models.expense_update import ExpenseUpdate


class ExpensesApiImpl(BaseExpensesApi):
    def __init__(self):
        self.expense_service = get_expense_service()

    async def groups_group_id_activities_activity_id_expenses_get(
        self, group_id: str, activity_id: str
    ) -> list[Expense]:
        return await self.expense_service.list_expenses(activity_id=activity_id)

    async def groups_group_id_activities_activity_id_expenses_post(
        self, group_id: str, activity_id: str, expense_create: ExpenseCreate
    ) -> Expense:
        expense = Expense(
            description=expense_create.description,
            amount=expense_create.amount,
            currency=expense_create.currency,
            paidBy=expense_create.paid_by,
            involved=expense_create.involved,
            date=expense_create.var_date,
        )
        return await self.expense_service.create_expense(
            expense=expense,
            activity_id=activity_id,
            equal_split=expense_create.equal_split,
        )

    async def groups_group_id_activities_activity_id_expenses_expense_id_get(
        self, group_id: str, activity_id: str, expense_id: str
    ) -> Expense:
        return await self.expense_service.get_expense(
            activity_id=activity_id, expense_id=expense_id
        )

    async def groups_group_id_activities_activity_id_expenses_expense_id_put(
        self,
        group_id: str,
        activity_id: str,
        expense_id: str,
        expense_update: ExpenseUpdate,
    ) -> Expense:
        expense = Expense(
            id=expense_id,
            description=expense_update.description,
            amount=expense_update.amount,
            currency=expense_update.currency,
            paidBy=expense_update.paid_by,
            involved=expense_update.involved,
            date=expense_update.var_date,
        )
        return await self.expense_service.update_expense(
            activity_id=activity_id,
            expense_id=expense_id,
            expense=expense,
            equal_split=expense_update.equal_split,
        )

    async def groups_group_id_activities_activity_id_expenses_expense_id_delete(
        self, group_id: str, activity_id: str, expense_id: str
    ) -> None:
        await self.expense_service.delete_expense(
            activity_id=activity_id, expense_id=expense_id
        )
        return Response(status_code=status.HTTP_204_NO_CONTENT)
