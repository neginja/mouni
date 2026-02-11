from api_server.impl.errors import NotFoundError
from api_server.impl.persistence.member_repository import MemberRepository
from api_server.impl.utils import logger_from_env
from api_server.models.member import Member

logger = logger_from_env("MemberService")


class MemberService:
    def __init__(self, member_repo: MemberRepository):
        self.member_repo = member_repo
        logger.debug("MemberService initialized with repository")

    async def create_member(self, group_id: str, member: Member) -> Member:
        logger.info(f"Creating member={member} in group_id={group_id}")
        created_member = self.member_repo.create(member=member, group_id=group_id)
        logger.info(f"Member created with id={created_member.id}")
        return created_member

    async def get_member(self, group_id: str, member_id: str) -> Member | None:
        logger.info(f"Fetching member id={member_id}")
        member = self.member_repo.get(group_id=group_id, member_id=member_id)
        if not member:
            logger.warning(f"Member id={member_id} not found")
            raise NotFoundError("Member not found")
        return member

    async def list_members(self, group_id: str) -> list[Member]:
        logger.info(f"Listing members for group {group_id}")
        members = self.member_repo.list_by_group(group_id=group_id)
        logger.debug(f"Members found ids={[m.id for m in members]}")
        return members

    async def update_member(
        self, group_id: str, member_id: str, member: Member
    ) -> Member | None:
        logger.info(f"Updating member id={member_id}, member={member}")
        updated_member = self.member_repo.update(
            group_id=group_id, member_id=member_id, member=member
        )
        if not updated_member:
            logger.warning(f"Member not found for update id={member_id}")
            raise NotFoundError("Member not found")
        logger.info(f"Member id={member_id} updated")
        return updated_member

    async def delete_member(self, group_id: str, member_id: str) -> None:
        member = await self.get_member(group_id=group_id, member_id=member_id)
        logger.info(f"Deleting member id={member.id}")
        self.member_repo.delete(group_id=group_id, member_id=member.id)
        logger.info(f"Member deleted id={member.id}")
