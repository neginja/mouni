# coding: utf-8

import importlib
import pkgutil
from typing import Any, Dict, List, Optional  # noqa: F401

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
from pydantic import Field, StrictStr, field_validator
from typing_extensions import Annotated

import api_server.impl
from api_server.apis.settlements_api_base import BaseSettlementsApi
from api_server.models.extra_models import TokenModel  # noqa: F401
from api_server.models.groups_group_id_activities_activity_id_settlements_settlement_id_patch_request import (
    GroupsGroupIdActivitiesActivityIdSettlementsSettlementIdPatchRequest,
)
from api_server.models.settlement import Settlement
from api_server.models.settlement_create import SettlementCreate

router = APIRouter()

ns_pkg = api_server.impl
for _, name, _ in pkgutil.iter_modules(ns_pkg.__path__, ns_pkg.__name__ + "."):
    importlib.import_module(name)


@router.post(
    "/groups/{groupId}/activities/{activityId}/settle",
    responses={
        200: {"model": List[Settlement], "description": "List of settlements"},
        404: {"description": "Not found"},
    },
    tags=["settlements"],
    summary="Settle an activity",
    response_model_by_alias=True,
)
async def groups_group_id_activities_activity_id_settle_post(
    groupId: Annotated[StrictStr, Field(description="The ID of the group")] = Path(..., description="The ID of the group"),
    activityId: Annotated[StrictStr, Field(description="The ID of the activity")] = Path(..., description="The ID of the activity"),
) -> List[Settlement]:
    if not BaseSettlementsApi.subclasses:
        raise HTTPException(status_code=500, detail="Not implemented")
    return await BaseSettlementsApi.subclasses[0]().groups_group_id_activities_activity_id_settle_post(groupId, activityId)


@router.delete(
    "/groups/{groupId}/activities/{activityId}/settlements",
    responses={
        204: {"description": "All settlements deleted successfully"},
        404: {"description": "Activity or group not found"},
    },
    tags=["settlements"],
    summary="Delete all settlements for a specific activity in a group",
    response_model_by_alias=True,
)
async def groups_group_id_activities_activity_id_settlements_delete(
    groupId: Annotated[StrictStr, Field(description="The ID of the group")] = Path(..., description="The ID of the group"),
    activityId: Annotated[StrictStr, Field(description="The ID of the activity")] = Path(..., description="The ID of the activity"),
) -> None:
    if not BaseSettlementsApi.subclasses:
        raise HTTPException(status_code=500, detail="Not implemented")
    return await BaseSettlementsApi.subclasses[0]().groups_group_id_activities_activity_id_settlements_delete(groupId, activityId)


@router.get(
    "/groups/{groupId}/activities/{activityId}/settlements",
    responses={
        200: {"model": List[Settlement], "description": "List of settlements"},
        404: {"description": "Not found"},
    },
    tags=["settlements"],
    summary="Get settlements showing who owes whom in a group",
    response_model_by_alias=True,
)
async def groups_group_id_activities_activity_id_settlements_get(
    groupId: Annotated[StrictStr, Field(description="The ID of the group")] = Path(..., description="The ID of the group"),
    activityId: Annotated[StrictStr, Field(description="The ID of the activity")] = Path(..., description="The ID of the activity"),
    simulate: Annotated[Optional[StrictStr], Field(description="if 'true' returns computed settlement but doesn't save and overwrite current")] = Query(None, description="if &#39;true&#39; returns computed settlement but doesn&#39;t save and overwrite current", alias="simulate"),
) -> List[Settlement]:
    if not BaseSettlementsApi.subclasses:
        raise HTTPException(status_code=500, detail="Not implemented")
    return await BaseSettlementsApi.subclasses[0]().groups_group_id_activities_activity_id_settlements_get(groupId, activityId, simulate)


@router.post(
    "/groups/{groupId}/activities/{activityId}/settlements",
    responses={
        201: {"model": Settlement, "description": "Created settlement"},
        404: {"description": "Not found"},
    },
    tags=["settlements"],
    summary="Create a settlement in a group",
    response_model_by_alias=True,
)
async def groups_group_id_activities_activity_id_settlements_post(
    groupId: Annotated[StrictStr, Field(description="The ID of the group")] = Path(..., description="The ID of the group"),
    activityId: Annotated[StrictStr, Field(description="The ID of the activity")] = Path(..., description="The ID of the activity"),
    settlement_create: SettlementCreate = Body(None, description=""),
) -> Settlement:
    if not BaseSettlementsApi.subclasses:
        raise HTTPException(status_code=500, detail="Not implemented")
    return await BaseSettlementsApi.subclasses[0]().groups_group_id_activities_activity_id_settlements_post(groupId, activityId, settlement_create)


@router.delete(
    "/groups/{groupId}/activities/{activityId}/settlements/{settlementId}",
    responses={
        204: {"description": "Settlement deleted"},
        404: {"description": "Not found"},
    },
    tags=["settlements"],
    summary="Delete a settlement",
    response_model_by_alias=True,
)
async def groups_group_id_activities_activity_id_settlements_settlement_id_delete(
    groupId: Annotated[StrictStr, Field(description="The ID of the group")] = Path(..., description="The ID of the group"),
    activityId: Annotated[StrictStr, Field(description="The ID of the activity")] = Path(..., description="The ID of the activity"),
    settlementId: Annotated[StrictStr, Field(description="The ID of the settlement")] = Path(..., description="The ID of the settlement"),
) -> None:
    if not BaseSettlementsApi.subclasses:
        raise HTTPException(status_code=500, detail="Not implemented")
    return await BaseSettlementsApi.subclasses[0]().groups_group_id_activities_activity_id_settlements_settlement_id_delete(groupId, activityId, settlementId)


@router.get(
    "/groups/{groupId}/activities/{activityId}/settlements/{settlementId}",
    responses={
        200: {"model": Settlement, "description": "Settlement details"},
        404: {"description": "Not found"},
    },
    tags=["settlements"],
    summary="Get a settlement detail",
    response_model_by_alias=True,
)
async def groups_group_id_activities_activity_id_settlements_settlement_id_get(
    groupId: Annotated[StrictStr, Field(description="The ID of the group")] = Path(..., description="The ID of the group"),
    activityId: Annotated[StrictStr, Field(description="The ID of the activity")] = Path(..., description="The ID of the activity"),
    settlementId: Annotated[StrictStr, Field(description="The ID of the settlement")] = Path(..., description="The ID of the settlement"),
) -> Settlement:
    if not BaseSettlementsApi.subclasses:
        raise HTTPException(status_code=500, detail="Not implemented")
    return await BaseSettlementsApi.subclasses[0]().groups_group_id_activities_activity_id_settlements_settlement_id_get(groupId, activityId, settlementId)


@router.patch(
    "/groups/{groupId}/activities/{activityId}/settlements/{settlementId}",
    responses={
        200: {"model": Settlement, "description": "Updated settlement with new paid (settled) status"},
        404: {"description": "Not found"},
    },
    tags=["settlements"],
    summary="Update settlement status",
    response_model_by_alias=True,
)
async def groups_group_id_activities_activity_id_settlements_settlement_id_patch(
    groupId: Annotated[StrictStr, Field(description="The ID of the group")] = Path(..., description="The ID of the group"),
    activityId: Annotated[StrictStr, Field(description="The ID of the activity")] = Path(..., description="The ID of the activity"),
    settlementId: Annotated[StrictStr, Field(description="The ID of the settlement")] = Path(..., description="The ID of the settlement"),
    groups_group_id_activities_activity_id_settlements_settlement_id_patch_request: GroupsGroupIdActivitiesActivityIdSettlementsSettlementIdPatchRequest = Body(None, description=""),
) -> Settlement:
    if not BaseSettlementsApi.subclasses:
        raise HTTPException(status_code=500, detail="Not implemented")
    return await BaseSettlementsApi.subclasses[0]().groups_group_id_activities_activity_id_settlements_settlement_id_patch(groupId, activityId, settlementId, groups_group_id_activities_activity_id_settlements_settlement_id_patch_request)
