from fastapi import Response, status

from api_server.apis.activities_api_base import BaseActivitiesApi
from api_server.impl.dependencies import get_activity_service
from api_server.models.activity import Activity
from api_server.models.activity_create import ActivityCreate
from api_server.models.groups_group_id_activities_activity_id_status_get200_response import (
    GroupsGroupIdActivitiesActivityIdStatusGet200Response,
)


class ActivitiesApiImpl(BaseActivitiesApi):
    def __init__(self):
        self.activity_service = get_activity_service()

    async def groups_group_id_activities_get(self, groupId: str) -> list[Activity]:
        return await self.activity_service.list_activities(group_id=groupId)

    async def groups_group_id_activities_post(
        self, groupId: str, activity_create: ActivityCreate
    ) -> Activity:
        activity = Activity(
            group_id=groupId,
            name=activity_create.name,
            start_date=activity_create.start_date,
            end_date=activity_create.end_date,
        )
        return await self.activity_service.create_activity(
            group_id=groupId, activity=activity
        )

    async def groups_group_id_activities_activity_id_get(
        self, groupId: str, activityId: str
    ) -> Activity:
        return await self.activity_service.get_activity(
            group_id=groupId, activity_id=activityId
        )

    async def groups_group_id_activities_activity_id_put(
        self, groupId: str, activityId: str, activity_update: Activity
    ) -> Activity:
        activity = Activity(
            id=activityId,
            group_id=groupId,
            name=activity_update.name,
            start_date=activity_update.start_date,
            end_date=activity_update.end_date,
        )
        return await self.activity_service.update_activity(
            group_id=groupId, activity_id=activityId, activity=activity
        )

    async def groups_group_id_activities_activity_id_delete(
        self, groupId: str, activityId: str
    ) -> None:
        await self.activity_service.delete_activity(
            group_id=groupId, activity_id=activityId
        )
        return Response(status_code=status.HTTP_204_NO_CONTENT)

    async def groups_group_id_activities_activity_id_status_get(
        self, groupId: str, activityId: str
    ) -> GroupsGroupIdActivitiesActivityIdStatusGet200Response:
        status = await self.activity_service.get_activity_settlement_status(
            group_id=groupId, activity_id=activityId
        )
        return GroupsGroupIdActivitiesActivityIdStatusGet200Response(status=status)
