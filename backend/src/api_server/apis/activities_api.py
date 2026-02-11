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
from api_server.apis.activities_api_base import BaseActivitiesApi
from api_server.models.activity import Activity
from api_server.models.activity_create import ActivityCreate
from api_server.models.activity_update import ActivityUpdate
from api_server.models.extra_models import TokenModel  # noqa: F401
from api_server.models.groups_group_id_activities_activity_id_status_get200_response import (
    GroupsGroupIdActivitiesActivityIdStatusGet200Response,
)

router = APIRouter()

ns_pkg = api_server.impl
for _, name, _ in pkgutil.iter_modules(ns_pkg.__path__, ns_pkg.__name__ + "."):
    importlib.import_module(name)


@router.delete(
    "/groups/{groupId}/activities/{activityId}",
    responses={
        204: {"description": "Activity deleted"},
        404: {"description": "Activity not found"},
    },
    tags=["activities"],
    summary="Delete an activity",
    response_model_by_alias=True,
)
async def groups_group_id_activities_activity_id_delete(
    groupId: Annotated[StrictStr, Field(description="The ID of the group")] = Path(..., description="The ID of the group"),
    activityId: Annotated[StrictStr, Field(description="The ID of the activity")] = Path(..., description="The ID of the activity"),
) -> None:
    if not BaseActivitiesApi.subclasses:
        raise HTTPException(status_code=500, detail="Not implemented")
    return await BaseActivitiesApi.subclasses[0]().groups_group_id_activities_activity_id_delete(groupId, activityId)


@router.get(
    "/groups/{groupId}/activities/{activityId}",
    responses={
        200: {"model": Activity, "description": "Activity details"},
        404: {"description": "Activity not found"},
    },
    tags=["activities"],
    summary="Get activity details",
    response_model_by_alias=True,
)
async def groups_group_id_activities_activity_id_get(
    groupId: Annotated[StrictStr, Field(description="The ID of the group")] = Path(..., description="The ID of the group"),
    activityId: Annotated[StrictStr, Field(description="The ID of the activity")] = Path(..., description="The ID of the activity"),
) -> Activity:
    if not BaseActivitiesApi.subclasses:
        raise HTTPException(status_code=500, detail="Not implemented")
    return await BaseActivitiesApi.subclasses[0]().groups_group_id_activities_activity_id_get(groupId, activityId)


@router.put(
    "/groups/{groupId}/activities/{activityId}",
    responses={
        200: {"model": Activity, "description": "Updated activity"},
        404: {"description": "Activity not found"},
    },
    tags=["activities"],
    summary="Update an activity",
    response_model_by_alias=True,
)
async def groups_group_id_activities_activity_id_put(
    groupId: Annotated[StrictStr, Field(description="The ID of the group")] = Path(..., description="The ID of the group"),
    activityId: Annotated[StrictStr, Field(description="The ID of the activity")] = Path(..., description="The ID of the activity"),
    activity_update: ActivityUpdate = Body(None, description=""),
) -> Activity:
    if not BaseActivitiesApi.subclasses:
        raise HTTPException(status_code=500, detail="Not implemented")
    return await BaseActivitiesApi.subclasses[0]().groups_group_id_activities_activity_id_put(groupId, activityId, activity_update)


@router.get(
    "/groups/{groupId}/activities/{activityId}/status",
    responses={
        200: {"model": GroupsGroupIdActivitiesActivityIdStatusGet200Response, "description": "Activity settlement status"},
        404: {"description": "Activity not found"},
    },
    tags=["activities"],
    summary="Get activity current settlement status",
    response_model_by_alias=True,
)
async def groups_group_id_activities_activity_id_status_get(
    groupId: Annotated[StrictStr, Field(description="The ID of the group")] = Path(..., description="The ID of the group"),
    activityId: Annotated[StrictStr, Field(description="The ID of the activity")] = Path(..., description="The ID of the activity"),
) -> GroupsGroupIdActivitiesActivityIdStatusGet200Response:
    if not BaseActivitiesApi.subclasses:
        raise HTTPException(status_code=500, detail="Not implemented")
    return await BaseActivitiesApi.subclasses[0]().groups_group_id_activities_activity_id_status_get(groupId, activityId)


@router.get(
    "/groups/{groupId}/activities",
    responses={
        200: {"model": List[Activity], "description": "List of activities"},
        404: {"description": "Not found"},
    },
    tags=["activities"],
    summary="List all activities in a group",
    response_model_by_alias=True,
)
async def groups_group_id_activities_get(
    groupId: Annotated[StrictStr, Field(description="The ID of the group")] = Path(..., description="The ID of the group"),
) -> List[Activity]:
    if not BaseActivitiesApi.subclasses:
        raise HTTPException(status_code=500, detail="Not implemented")
    return await BaseActivitiesApi.subclasses[0]().groups_group_id_activities_get(groupId)


@router.post(
    "/groups/{groupId}/activities",
    responses={
        201: {"model": Activity, "description": "Created activity"},
        404: {"description": "Not found"},
    },
    tags=["activities"],
    summary="Create a new activity in a group",
    response_model_by_alias=True,
)
async def groups_group_id_activities_post(
    groupId: Annotated[StrictStr, Field(description="The ID of the group")] = Path(..., description="The ID of the group"),
    activity_create: ActivityCreate = Body(None, description=""),
) -> Activity:
    if not BaseActivitiesApi.subclasses:
        raise HTTPException(status_code=500, detail="Not implemented")
    return await BaseActivitiesApi.subclasses[0]().groups_group_id_activities_post(groupId, activity_create)
