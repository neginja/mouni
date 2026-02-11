# coding: utf-8

from typing import Any, ClassVar, Dict, List, Optional, Tuple  # noqa: F401

from pydantic import Field, StrictStr, field_validator
from typing_extensions import Annotated

from api_server.models.groups_group_id_activities_activity_id_settlements_settlement_id_patch_request import (
    GroupsGroupIdActivitiesActivityIdSettlementsSettlementIdPatchRequest,
)
from api_server.models.settlement import Settlement
from api_server.models.settlement_create import SettlementCreate


class BaseSettlementsApi:
    subclasses: ClassVar[Tuple] = ()

    def __init_subclass__(cls, **kwargs):
        super().__init_subclass__(**kwargs)
        BaseSettlementsApi.subclasses = BaseSettlementsApi.subclasses + (cls,)
    async def groups_group_id_activities_activity_id_settle_post(
        self,
        groupId: Annotated[StrictStr, Field(description="The ID of the group")],
        activityId: Annotated[StrictStr, Field(description="The ID of the activity")],
    ) -> List[Settlement]:
        ...


    async def groups_group_id_activities_activity_id_settlements_delete(
        self,
        groupId: Annotated[StrictStr, Field(description="The ID of the group")],
        activityId: Annotated[StrictStr, Field(description="The ID of the activity")],
    ) -> None:
        ...


    async def groups_group_id_activities_activity_id_settlements_get(
        self,
        groupId: Annotated[StrictStr, Field(description="The ID of the group")],
        activityId: Annotated[StrictStr, Field(description="The ID of the activity")],
        simulate: Annotated[Optional[StrictStr], Field(description="if 'true' returns computed settlement but doesn't save and overwrite current")],
    ) -> List[Settlement]:
        ...


    async def groups_group_id_activities_activity_id_settlements_post(
        self,
        groupId: Annotated[StrictStr, Field(description="The ID of the group")],
        activityId: Annotated[StrictStr, Field(description="The ID of the activity")],
        settlement_create: SettlementCreate,
    ) -> Settlement:
        ...


    async def groups_group_id_activities_activity_id_settlements_settlement_id_delete(
        self,
        groupId: Annotated[StrictStr, Field(description="The ID of the group")],
        activityId: Annotated[StrictStr, Field(description="The ID of the activity")],
        settlementId: Annotated[StrictStr, Field(description="The ID of the settlement")],
    ) -> None:
        ...


    async def groups_group_id_activities_activity_id_settlements_settlement_id_get(
        self,
        groupId: Annotated[StrictStr, Field(description="The ID of the group")],
        activityId: Annotated[StrictStr, Field(description="The ID of the activity")],
        settlementId: Annotated[StrictStr, Field(description="The ID of the settlement")],
    ) -> Settlement:
        ...


    async def groups_group_id_activities_activity_id_settlements_settlement_id_patch(
        self,
        groupId: Annotated[StrictStr, Field(description="The ID of the group")],
        activityId: Annotated[StrictStr, Field(description="The ID of the activity")],
        settlementId: Annotated[StrictStr, Field(description="The ID of the settlement")],
        groups_group_id_activities_activity_id_settlements_settlement_id_patch_request: GroupsGroupIdActivitiesActivityIdSettlementsSettlementIdPatchRequest,
    ) -> Settlement:
        ...
