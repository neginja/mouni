from api_server.impl.errors import NotFoundError
from api_server.impl.persistence.group_repository import GroupRepository
from api_server.impl.persistence.member_repository import MemberRepository
from api_server.impl.utils import logger_from_env
from api_server.models.group import Group

logger = logger_from_env("GroupService")


class GroupService:
    def __init__(
        self,
        group_repo: GroupRepository,
        member_repo: MemberRepository,
    ) -> None:
        self.group_repo = group_repo
        self.member_repo = member_repo
        logger.debug("GroupService initialized")

    async def create_group(self, group: Group) -> Group:
        logger.info(f"Creating group={group}")
        created_group = self.group_repo.create(group=group)
        logger.info(f"Group created with ID: {created_group.id}")
        return created_group

    async def get_group(self, group_id: str) -> Group | None:
        logger.info(f"Fetching group with id={group_id}")
        group = self.group_repo.get(group_id)
        if not group:
            logger.warning(f"Group id={group_id} not found")
            raise NotFoundError("Group not found")

        members = self.member_repo.list_by_group(group_id=group_id)
        group.members = members
        logger.debug(f"Group member_ids={[m.id for m in members]} fetched")
        return group

    async def list_groups(self) -> list[Group]:
        logger.info("Listing all groups")
        groups = self.group_repo.list()
        group_list = []

        for group in groups:
            members = self.member_repo.list_by_group(group_id=group.id)
            group.members = members
            group_list.append(group)
            logger.debug(f"Group {group.id} members: {[m.id for m in members]}")

        logger.info(f"Total groups listed: {len(group_list)}")
        return group_list

    async def update_group(self, group_id: str, group: Group) -> Group | None:
        logger.info(f"Updating group id={group_id}, group={group}")
        updated_group = self.group_repo.update(group_id=group_id, group=group)
        if updated_group:
            logger.info(f"Group updated: {group_id}")
            return updated_group
        else:
            logger.warning(f"Group not found for update: {group_id}")
            raise NotFoundError("Group not found")

    async def delete_group(self, group_id: str) -> None:
        group = await self.get_group(group_id=group_id)
        logger.info(f"Deleting group with id={group.id}")
        self.group_repo.delete(group_id=group.id)
        logger.info(f"Group id={group.id} deleted")
