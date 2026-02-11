from fastapi import Response, status

from api_server.apis.members_api_base import BaseMembersApi
from api_server.impl.dependencies import get_member_service
from api_server.models.member import Member
from api_server.models.member_create import MemberCreate
from api_server.models.member_update import MemberUpdate


class MembersApiImpl(BaseMembersApi):
    def __init__(self) -> None:
        self.member_service = get_member_service()

    async def groups_group_id_members_get(self, groupId: str) -> list[Member]:
        return await self.member_service.list_members(group_id=groupId)

    async def groups_group_id_members_post(
        self, groupId: str, member_create: MemberCreate
    ) -> Member:
        member = Member(id=None, name=member_create.name)
        return await self.member_service.create_member(
            group_id=groupId,
            member=member,
        )

    async def groups_group_id_members_member_id_get(
        self, groupId: str, memberId: str
    ) -> Member:
        return await self.member_service.get_member(
            group_id=groupId, member_id=memberId
        )

    async def groups_group_id_members_member_id_put(
        self, groupId: str, memberId: str, member_update: MemberUpdate
    ) -> Member:
        member = Member(id=memberId, name=member_update.name)
        return await self.member_service.update_member(
            group_id=groupId, member_id=memberId, member=member
        )

    async def groups_group_id_members_member_id_delete(
        self, groupId: str, memberId: str
    ) -> None:
        await self.member_service.delete_member(group_id=groupId, member_id=memberId)
        return Response(status_code=status.HTTP_204_NO_CONTENT)
