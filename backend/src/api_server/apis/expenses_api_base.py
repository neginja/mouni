# coding: utf-8

from typing import Any, ClassVar, Dict, List, Tuple  # noqa: F401

from pydantic import Field, StrictStr
from typing_extensions import Annotated

from api_server.models.expense import Expense
from api_server.models.expense_create import ExpenseCreate
from api_server.models.expense_update import ExpenseUpdate


class BaseExpensesApi:
    subclasses: ClassVar[Tuple] = ()

    def __init_subclass__(cls, **kwargs):
        super().__init_subclass__(**kwargs)
        BaseExpensesApi.subclasses = BaseExpensesApi.subclasses + (cls,)
    async def groups_group_id_activities_activity_id_expenses_expense_id_delete(
        self,
        groupId: Annotated[StrictStr, Field(description="The ID of the group")],
        activityId: Annotated[StrictStr, Field(description="The ID of the activity")],
        expenseId: Annotated[StrictStr, Field(description="The ID of the expense")],
    ) -> None:
        ...


    async def groups_group_id_activities_activity_id_expenses_expense_id_get(
        self,
        groupId: Annotated[StrictStr, Field(description="The ID of the group")],
        activityId: Annotated[StrictStr, Field(description="The ID of the activity")],
        expenseId: Annotated[StrictStr, Field(description="The ID of the expense")],
    ) -> Expense:
        ...


    async def groups_group_id_activities_activity_id_expenses_expense_id_put(
        self,
        groupId: Annotated[StrictStr, Field(description="The ID of the group")],
        activityId: Annotated[StrictStr, Field(description="The ID of the activity")],
        expenseId: Annotated[StrictStr, Field(description="The ID of the expense")],
        expense_update: ExpenseUpdate,
    ) -> Expense:
        ...


    async def groups_group_id_activities_activity_id_expenses_get(
        self,
        groupId: Annotated[StrictStr, Field(description="The ID of the group")],
        activityId: Annotated[StrictStr, Field(description="The ID of the activity")],
    ) -> List[Expense]:
        ...


    async def groups_group_id_activities_activity_id_expenses_post(
        self,
        groupId: Annotated[StrictStr, Field(description="The ID of the group")],
        activityId: Annotated[StrictStr, Field(description="The ID of the activity")],
        expense_create: ExpenseCreate,
    ) -> Expense:
        ...
