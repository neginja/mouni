from enum import Enum

from api_server.impl.errors import NotFoundError
from api_server.impl.persistence.activity_repository import ActivityRepository
from api_server.impl.persistence.settlement_repository import (
    SettlementRepository,
)
from api_server.impl.utils import logger_from_env
from api_server.models.activity import Activity


class SettlementStatus(str, Enum):
    NOT_SETTLED = "not_settled"
    PARTIALLY_SETTLED = "partially_settled"
    SETTLED = "settled"


logger = logger_from_env("ActivityService")


class ActivityService:
    def __init__(
        self, activity_repo: ActivityRepository, settlements_repo: SettlementRepository
    ) -> None:
        self.activity_repo = activity_repo
        self.settlement_repo = settlements_repo
        logger.debug(f"ActivityService initialized with repository {activity_repo}")

    async def create_activity(self, group_id: str, activity: Activity) -> Activity:
        logger.info(f"Creating activity: {activity}")
        created = self.activity_repo.create(group_id, activity)
        logger.info(f"Created activity with ID: {created.id}")
        return created

    async def get_activity(self, group_id: str, activity_id: str) -> Activity | None:
        logger.info(f"Fetching activity with ID: {activity_id}")
        activity = self.activity_repo.get(group_id, activity_id)
        if activity:
            logger.debug(f"Found activity: {activity}")
            return activity
        else:
            logger.warning(f"Activity not found: {activity_id}")
            raise NotFoundError("Activity not found")

    async def list_activities(self, group_id: str) -> list[Activity]:
        logger.info(f"Listing activities for group: {group_id}")
        activities = self.activity_repo.list_by_group(group_id)
        logger.debug(f"Found {len(activities)} activities for group {group_id}")
        return activities

    async def update_activity(
        self, group_id: str, activity_id: str, activity: Activity
    ) -> Activity | None:
        logger.info(f"Updating activity id={activity_id} with new data: {activity}")
        updated = self.activity_repo.update(group_id, activity_id, activity)
        if updated:
            logger.info(f"Activity {activity_id} updated successfully")
            return updated
        else:
            logger.warning(f"Activity id={activity_id} not found for update")
            raise NotFoundError("Activity not found")

    async def delete_activity(self, group_id: str, activity_id: str) -> None:
        activity = await self.get_activity(group_id, activity_id)
        logger.info(f"Deleting activity with ID: {activity.id}")
        self.activity_repo.delete(group_id=group_id, activity_id=activity.id)
        logger.info(f"Deleted activity with ID: {activity.id}")

    async def get_activity_settlement_status(
        self, group_id: str, activity_id: str
    ) -> str:
        settlements = self.settlement_repo.list_by_activity(activity_id)

        if not settlements:
            status = SettlementStatus.NOT_SETTLED
        else:
            total = len(settlements)
            paid_count = sum(1 for s in settlements if s.paid)
            if paid_count == 0:
                status = SettlementStatus.NOT_SETTLED
            elif paid_count < total:
                status = SettlementStatus.PARTIALLY_SETTLED
            else:
                status = SettlementStatus.SETTLED

        return status
