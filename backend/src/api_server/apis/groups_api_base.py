# coding: utf-8

from typing import Any, ClassVar, Dict, List, Tuple  # noqa: F401

from pydantic import Field, StrictStr
from typing_extensions import Annotated

from api_server.models.group import Group
from api_server.models.group_create import GroupCreate
from api_server.models.group_update import GroupUpdate


class BaseGroupsApi:
    subclasses: ClassVar[Tuple] = ()

    def __init_subclass__(cls, **kwargs):
        super().__init_subclass__(**kwargs)
        BaseGroupsApi.subclasses = BaseGroupsApi.subclasses + (cls,)
    async def groups_get(
        self,
    ) -> List[Group]:
        ...


    async def groups_group_id_delete(
        self,
        groupId: Annotated[StrictStr, Field(description="The ID of the group")],
    ) -> None:
        ...


    async def groups_group_id_get(
        self,
        groupId: Annotated[StrictStr, Field(description="The ID of the group")],
    ) -> Group:
        ...


    async def groups_group_id_put(
        self,
        groupId: Annotated[StrictStr, Field(description="The ID of the group")],
        group_update: GroupUpdate,
    ) -> Group:
        ...


    async def groups_post(
        self,
        group_create: GroupCreate,
    ) -> Group:
        ...
