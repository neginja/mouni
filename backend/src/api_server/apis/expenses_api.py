# coding: utf-8

import importlib
import pkgutil
from typing import Any, Dict, List  # noqa: F401

from fastapi import (  # noqa: F401
    APIRouter,
    Body,
    Cookie,
    Depends,
    Form,
    Header,
    HTTPException,
    Path,
    Query,
    Response,
    Security,
    status,
)
from pydantic import Field, StrictStr
from typing_extensions import Annotated

import api_server.impl
from api_server.apis.expenses_api_base import BaseExpensesApi
from api_server.models.expense import Expense
from api_server.models.expense_create import ExpenseCreate
from api_server.models.expense_update import ExpenseUpdate
from api_server.models.extra_models import TokenModel  # noqa: F401

router = APIRouter()

ns_pkg = api_server.impl
for _, name, _ in pkgutil.iter_modules(ns_pkg.__path__, ns_pkg.__name__ + "."):
    importlib.import_module(name)


@router.delete(
    "/groups/{groupId}/activities/{activityId}/expenses/{expenseId}",
    responses={
        204: {"description": "Expense deleted"},
        404: {"description": "Activity or expense not found"},
    },
    tags=["expenses"],
    summary="Delete an expense",
    response_model_by_alias=True,
)
async def groups_group_id_activities_activity_id_expenses_expense_id_delete(
    groupId: Annotated[StrictStr, Field(description="The ID of the group")] = Path(..., description="The ID of the group"),
    activityId: Annotated[StrictStr, Field(description="The ID of the activity")] = Path(..., description="The ID of the activity"),
    expenseId: Annotated[StrictStr, Field(description="The ID of the expense")] = Path(..., description="The ID of the expense"),
) -> None:
    if not BaseExpensesApi.subclasses:
        raise HTTPException(status_code=500, detail="Not implemented")
    return await BaseExpensesApi.subclasses[0]().groups_group_id_activities_activity_id_expenses_expense_id_delete(groupId, activityId, expenseId)


@router.get(
    "/groups/{groupId}/activities/{activityId}/expenses/{expenseId}",
    responses={
        200: {"model": Expense, "description": "Expense details"},
        404: {"description": "Activity or expense not found"},
    },
    tags=["expenses"],
    summary="Get expense details",
    response_model_by_alias=True,
)
async def groups_group_id_activities_activity_id_expenses_expense_id_get(
    groupId: Annotated[StrictStr, Field(description="The ID of the group")] = Path(..., description="The ID of the group"),
    activityId: Annotated[StrictStr, Field(description="The ID of the activity")] = Path(..., description="The ID of the activity"),
    expenseId: Annotated[StrictStr, Field(description="The ID of the expense")] = Path(..., description="The ID of the expense"),
) -> Expense:
    if not BaseExpensesApi.subclasses:
        raise HTTPException(status_code=500, detail="Not implemented")
    return await BaseExpensesApi.subclasses[0]().groups_group_id_activities_activity_id_expenses_expense_id_get(groupId, activityId, expenseId)


@router.put(
    "/groups/{groupId}/activities/{activityId}/expenses/{expenseId}",
    responses={
        200: {"model": Expense, "description": "Updated expense"},
        404: {"description": "Activity or expense not found"},
    },
    tags=["expenses"],
    summary="Update an expense in an activity",
    response_model_by_alias=True,
)
async def groups_group_id_activities_activity_id_expenses_expense_id_put(
    groupId: Annotated[StrictStr, Field(description="The ID of the group")] = Path(..., description="The ID of the group"),
    activityId: Annotated[StrictStr, Field(description="The ID of the activity")] = Path(..., description="The ID of the activity"),
    expenseId: Annotated[StrictStr, Field(description="The ID of the expense")] = Path(..., description="The ID of the expense"),
    expense_update: ExpenseUpdate = Body(None, description=""),
) -> Expense:
    if not BaseExpensesApi.subclasses:
        raise HTTPException(status_code=500, detail="Not implemented")
    return await BaseExpensesApi.subclasses[0]().groups_group_id_activities_activity_id_expenses_expense_id_put(groupId, activityId, expenseId, expense_update)


@router.get(
    "/groups/{groupId}/activities/{activityId}/expenses",
    responses={
        200: {"model": List[Expense], "description": "List of expenses"},
        404: {"description": "Activity not found"},
    },
    tags=["expenses"],
    summary="List expenses in an activity",
    response_model_by_alias=True,
)
async def groups_group_id_activities_activity_id_expenses_get(
    groupId: Annotated[StrictStr, Field(description="The ID of the group")] = Path(..., description="The ID of the group"),
    activityId: Annotated[StrictStr, Field(description="The ID of the activity")] = Path(..., description="The ID of the activity"),
) -> List[Expense]:
    if not BaseExpensesApi.subclasses:
        raise HTTPException(status_code=500, detail="Not implemented")
    return await BaseExpensesApi.subclasses[0]().groups_group_id_activities_activity_id_expenses_get(groupId, activityId)


@router.post(
    "/groups/{groupId}/activities/{activityId}/expenses",
    responses={
        201: {"model": Expense, "description": "Expense created"},
        404: {"description": "Activity or member not found"},
    },
    tags=["expenses"],
    summary="Add an expense to an activity",
    response_model_by_alias=True,
)
async def groups_group_id_activities_activity_id_expenses_post(
    groupId: Annotated[StrictStr, Field(description="The ID of the group")] = Path(..., description="The ID of the group"),
    activityId: Annotated[StrictStr, Field(description="The ID of the activity")] = Path(..., description="The ID of the activity"),
    expense_create: ExpenseCreate = Body(None, description=""),
) -> Expense:
    if not BaseExpensesApi.subclasses:
        raise HTTPException(status_code=500, detail="Not implemented")
    return await BaseExpensesApi.subclasses[0]().groups_group_id_activities_activity_id_expenses_post(groupId, activityId, expense_create)
