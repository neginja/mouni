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
from api_server.apis.members_api_base import BaseMembersApi
from api_server.models.extra_models import TokenModel  # noqa: F401
from api_server.models.member import Member
from api_server.models.member_create import MemberCreate
from api_server.models.member_update import MemberUpdate

router = APIRouter()

ns_pkg = api_server.impl
for _, name, _ in pkgutil.iter_modules(ns_pkg.__path__, ns_pkg.__name__ + "."):
    importlib.import_module(name)


@router.get(
    "/groups/{groupId}/members",
    responses={
        200: {"model": List[Member], "description": "List of members"},
        404: {"description": "Not found"},
    },
    tags=["members"],
    summary="List members of a group",
    response_model_by_alias=True,
)
async def groups_group_id_members_get(
    groupId: Annotated[StrictStr, Field(description="The ID of the group")] = Path(..., description="The ID of the group"),
) -> List[Member]:
    if not BaseMembersApi.subclasses:
        raise HTTPException(status_code=500, detail="Not implemented")
    return await BaseMembersApi.subclasses[0]().groups_group_id_members_get(groupId)


@router.delete(
    "/groups/{groupId}/members/{memberId}",
    responses={
        204: {"description": "Member removed"},
        404: {"description": "Group or member not found"},
    },
    tags=["members"],
    summary="Remove a member from a group",
    response_model_by_alias=True,
)
async def groups_group_id_members_member_id_delete(
    groupId: Annotated[StrictStr, Field(description="The ID of the group")] = Path(..., description="The ID of the group"),
    memberId: Annotated[StrictStr, Field(description="The ID of the member")] = Path(..., description="The ID of the member"),
) -> None:
    if not BaseMembersApi.subclasses:
        raise HTTPException(status_code=500, detail="Not implemented")
    return await BaseMembersApi.subclasses[0]().groups_group_id_members_member_id_delete(groupId, memberId)


@router.get(
    "/groups/{groupId}/members/{memberId}",
    responses={
        200: {"model": Member, "description": "Member details"},
        404: {"description": "Group or member not found"},
    },
    tags=["members"],
    summary="Get a member&#39;s details in a group",
    response_model_by_alias=True,
)
async def groups_group_id_members_member_id_get(
    groupId: Annotated[StrictStr, Field(description="The ID of the group")] = Path(..., description="The ID of the group"),
    memberId: Annotated[StrictStr, Field(description="The ID of the member")] = Path(..., description="The ID of the member"),
) -> Member:
    if not BaseMembersApi.subclasses:
        raise HTTPException(status_code=500, detail="Not implemented")
    return await BaseMembersApi.subclasses[0]().groups_group_id_members_member_id_get(groupId, memberId)


@router.put(
    "/groups/{groupId}/members/{memberId}",
    responses={
        200: {"model": Member, "description": "Updated member"},
        404: {"description": "Group or member not found"},
    },
    tags=["members"],
    summary="Update a member in a group",
    response_model_by_alias=True,
)
async def groups_group_id_members_member_id_put(
    groupId: Annotated[StrictStr, Field(description="The ID of the group")] = Path(..., description="The ID of the group"),
    memberId: Annotated[StrictStr, Field(description="The ID of the member")] = Path(..., description="The ID of the member"),
    member_update: MemberUpdate = Body(None, description=""),
) -> Member:
    if not BaseMembersApi.subclasses:
        raise HTTPException(status_code=500, detail="Not implemented")
    return await BaseMembersApi.subclasses[0]().groups_group_id_members_member_id_put(groupId, memberId, member_update)


@router.post(
    "/groups/{groupId}/members",
    responses={
        201: {"model": Member, "description": "Member added"},
        404: {"description": "Not found"},
    },
    tags=["members"],
    summary="Add a member to group",
    response_model_by_alias=True,
)
async def groups_group_id_members_post(
    groupId: Annotated[StrictStr, Field(description="The ID of the group")] = Path(..., description="The ID of the group"),
    member_create: MemberCreate = Body(None, description=""),
) -> Member:
    if not BaseMembersApi.subclasses:
        raise HTTPException(status_code=500, detail="Not implemented")
    return await BaseMembersApi.subclasses[0]().groups_group_id_members_post(groupId, member_create)
