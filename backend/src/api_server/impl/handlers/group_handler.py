from fastapi import Response, status

from api_server.apis.groups_api_base import BaseGroupsApi
from api_server.impl.dependencies import get_group_service
from api_server.models.group import Group
from api_server.models.group_create import GroupCreate
from api_server.models.group_update import GroupUpdate


class GroupsApiImpl(BaseGroupsApi):
    def __init__(self) -> None:
        self.group_service = get_group_service()

    async def groups_get(self) -> list[Group]:
        return await self.group_service.list_groups()

    async def groups_post(self, group_create: GroupCreate) -> Group:
        group = Group(id=None, name=group_create.name, members=[])
        return await self.group_service.create_group(group=group)

    async def groups_group_id_get(self, groupId: str) -> Group:
        return await self.group_service.get_group(group_id=groupId)

    async def groups_group_id_put(
        self, groupId: str, group_update: GroupUpdate
    ) -> Group:
        group = Group(id=groupId, name=group_update.name, members=[])
        return await self.group_service.update_group(group_id=groupId, group=group)

    async def groups_group_id_delete(self, groupId: str) -> None:
        await self.group_service.delete_group(group_id=groupId)
        return Response(status_code=status.HTTP_204_NO_CONTENT)
