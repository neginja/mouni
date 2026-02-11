# coding: utf-8

from typing import Any, ClassVar, Dict, List, Tuple  # noqa: F401

from pydantic import Field, StrictStr
from typing_extensions import Annotated

from api_server.models.activity import Activity
from api_server.models.activity_create import ActivityCreate
from api_server.models.activity_update import ActivityUpdate
from api_server.models.groups_group_id_activities_activity_id_status_get200_response import (
    GroupsGroupIdActivitiesActivityIdStatusGet200Response,
)


class BaseActivitiesApi:
    subclasses: ClassVar[Tuple] = ()

    def __init_subclass__(cls, **kwargs):
        super().__init_subclass__(**kwargs)
        BaseActivitiesApi.subclasses = BaseActivitiesApi.subclasses + (cls,)
    async def groups_group_id_activities_activity_id_delete(
        self,
        groupId: Annotated[StrictStr, Field(description="The ID of the group")],
        activityId: Annotated[StrictStr, Field(description="The ID of the activity")],
    ) -> None:
        ...


    async def groups_group_id_activities_activity_id_get(
        self,
        groupId: Annotated[StrictStr, Field(description="The ID of the group")],
        activityId: Annotated[StrictStr, Field(description="The ID of the activity")],
    ) -> Activity:
        ...


    async def groups_group_id_activities_activity_id_put(
        self,
        groupId: Annotated[StrictStr, Field(description="The ID of the group")],
        activityId: Annotated[StrictStr, Field(description="The ID of the activity")],
        activity_update: ActivityUpdate,
    ) -> Activity:
        ...


    async def groups_group_id_activities_activity_id_status_get(
        self,
        groupId: Annotated[StrictStr, Field(description="The ID of the group")],
        activityId: Annotated[StrictStr, Field(description="The ID of the activity")],
    ) -> GroupsGroupIdActivitiesActivityIdStatusGet200Response:
        ...


    async def groups_group_id_activities_get(
        self,
        groupId: Annotated[StrictStr, Field(description="The ID of the group")],
    ) -> List[Activity]:
        ...


    async def groups_group_id_activities_post(
        self,
        groupId: Annotated[StrictStr, Field(description="The ID of the group")],
        activity_create: ActivityCreate,
    ) -> Activity:
        ...
