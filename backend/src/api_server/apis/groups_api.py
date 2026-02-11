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
from api_server.apis.groups_api_base import BaseGroupsApi
from api_server.models.extra_models import TokenModel  # noqa: F401
from api_server.models.group import Group
from api_server.models.group_create import GroupCreate
from api_server.models.group_update import GroupUpdate

router = APIRouter()

ns_pkg = api_server.impl
for _, name, _ in pkgutil.iter_modules(ns_pkg.__path__, ns_pkg.__name__ + "."):
    importlib.import_module(name)


@router.get(
    "/groups",
    responses={
        200: {"model": List[Group], "description": "List of groups"},
    },
    tags=["groups"],
    summary="List all groups",
    response_model_by_alias=True,
)
async def groups_get(
) -> List[Group]:
    if not BaseGroupsApi.subclasses:
        raise HTTPException(status_code=500, detail="Not implemented")
    return await BaseGroupsApi.subclasses[0]().groups_get()


@router.delete(
    "/groups/{groupId}",
    responses={
        204: {"description": "Group deleted"},
        404: {"description": "Not found"},
    },
    tags=["groups"],
    summary="Delete a group",
    response_model_by_alias=True,
)
async def groups_group_id_delete(
    groupId: Annotated[StrictStr, Field(description="The ID of the group")] = Path(..., description="The ID of the group"),
) -> None:
    if not BaseGroupsApi.subclasses:
        raise HTTPException(status_code=500, detail="Not implemented")
    return await BaseGroupsApi.subclasses[0]().groups_group_id_delete(groupId)


@router.get(
    "/groups/{groupId}",
    responses={
        200: {"model": Group, "description": "Group details"},
        404: {"description": "Not found"},
    },
    tags=["groups"],
    summary="Get group details",
    response_model_by_alias=True,
)
async def groups_group_id_get(
    groupId: Annotated[StrictStr, Field(description="The ID of the group")] = Path(..., description="The ID of the group"),
) -> Group:
    if not BaseGroupsApi.subclasses:
        raise HTTPException(status_code=500, detail="Not implemented")
    return await BaseGroupsApi.subclasses[0]().groups_group_id_get(groupId)


@router.put(
    "/groups/{groupId}",
    responses={
        200: {"model": Group, "description": "Updated group"},
        404: {"description": "Not found"},
    },
    tags=["groups"],
    summary="Update a group",
    response_model_by_alias=True,
)
async def groups_group_id_put(
    groupId: Annotated[StrictStr, Field(description="The ID of the group")] = Path(..., description="The ID of the group"),
    group_update: GroupUpdate = Body(None, description=""),
) -> Group:
    if not BaseGroupsApi.subclasses:
        raise HTTPException(status_code=500, detail="Not implemented")
    return await BaseGroupsApi.subclasses[0]().groups_group_id_put(groupId, group_update)


@router.post(
    "/groups",
    responses={
        201: {"model": Group, "description": "Created group"},
    },
    tags=["groups"],
    summary="Create a new group",
    response_model_by_alias=True,
)
async def groups_post(
    group_create: GroupCreate = Body(None, description=""),
) -> Group:
    if not BaseGroupsApi.subclasses:
        raise HTTPException(status_code=500, detail="Not implemented")
    return await BaseGroupsApi.subclasses[0]().groups_post(group_create)
