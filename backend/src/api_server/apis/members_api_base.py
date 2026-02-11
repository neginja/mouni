# coding: utf-8

from typing import Any, ClassVar, Dict, List, Tuple  # noqa: F401

from pydantic import Field, StrictStr
from typing_extensions import Annotated

from api_server.models.member import Member
from api_server.models.member_create import MemberCreate
from api_server.models.member_update import MemberUpdate


class BaseMembersApi:
    subclasses: ClassVar[Tuple] = ()

    def __init_subclass__(cls, **kwargs):
        super().__init_subclass__(**kwargs)
        BaseMembersApi.subclasses = BaseMembersApi.subclasses + (cls,)
    async def groups_group_id_members_get(
        self,
        groupId: Annotated[StrictStr, Field(description="The ID of the group")],
    ) -> List[Member]:
        ...


    async def groups_group_id_members_member_id_delete(
        self,
        groupId: Annotated[StrictStr, Field(description="The ID of the group")],
        memberId: Annotated[StrictStr, Field(description="The ID of the member")],
    ) -> None:
        ...


    async def groups_group_id_members_member_id_get(
        self,
        groupId: Annotated[StrictStr, Field(description="The ID of the group")],
        memberId: Annotated[StrictStr, Field(description="The ID of the member")],
    ) -> Member:
        ...


    async def groups_group_id_members_member_id_put(
        self,
        groupId: Annotated[StrictStr, Field(description="The ID of the group")],
        memberId: Annotated[StrictStr, Field(description="The ID of the member")],
        member_update: MemberUpdate,
    ) -> Member:
        ...


    async def groups_group_id_members_post(
        self,
        groupId: Annotated[StrictStr, Field(description="The ID of the group")],
        member_create: MemberCreate,
    ) -> Member:
        ...
