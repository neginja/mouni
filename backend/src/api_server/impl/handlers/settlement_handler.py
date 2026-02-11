from fastapi import HTTPException, Response, status

from api_server.apis.settlements_api_base import BaseSettlementsApi
from api_server.impl.dependencies import get_settlement_service
from api_server.models.groups_group_id_activities_activity_id_settlements_settlement_id_patch_request import (
    GroupsGroupIdActivitiesActivityIdSettlementsSettlementIdPatchRequest,
)
from api_server.models.settlement import Settlement
from api_server.models.settlement_create import SettlementCreate


class SettlementsApiImpl(BaseSettlementsApi):
    def __init__(
        self,
    ) -> None:
        self.settlement_service = get_settlement_service()

    async def groups_group_id_activities_activity_id_settlements_get(
        self, group_id: str, activity_id: str, simulate: bool
    ) -> list[Settlement]:
        if simulate and simulate.lower() == "true":
            return await self.settlement_service.compute_current_settlement(activity_id)

        return await self.settlement_service.list_settlements(activity_id)

    async def groups_group_id_activities_activity_id_settlements_post(
        self,
        group_id: str,
        activity_id: str,
        settlement_create: SettlementCreate,
    ) -> Settlement:
        settlement = Settlement(
            fromMember=settlement_create.from_member,
            toMember=settlement_create.to_member,
            amount=settlement_create.amount,
            currency=settlement_create.currency,
        )
        return await self.settlement_service.create_settlement(
            activity_id=activity_id,
            settlement=settlement,
        )

    async def groups_group_id_activities_activity_id_settle_post(
        self,
        group_id: str,
        activity_id: str,
    ) -> Settlement:
        return await self.settlement_service.settle_activity(activity_id=activity_id)

    async def groups_group_id_activities_activity_id_settlements_settlement_id_get(
        self, group_id: str, activity_id: str, settlement_id: str
    ) -> Settlement:
        return await self.settlement_service.get_settlement(
            activity_id=activity_id, settlement_id=settlement_id
        )

    async def groups_group_id_activities_activity_id_settlements_settlement_id_patch(
        self,
        group_id: str,
        activity_id: str,
        settlement_id: str,
        req: GroupsGroupIdActivitiesActivityIdSettlementsSettlementIdPatchRequest,
    ) -> Settlement:
        updated = await self.settlement_service.update_paid_status(
            activity_id=activity_id, settlement_id=settlement_id, paid=req.paid
        )
        if not updated:
            raise HTTPException(
                status_code=404, detail="Activity or settlement not found"
            )
        return updated

    async def groups_group_id_activities_activity_id_settlements_settlement_id_delete(
        self, group_id: str, activity_id: str, settlement_id: str
    ) -> None:
        await self.settlement_service.delete_settlement(
            activity_id=activity_id, settlement_id=settlement_id
        )
        return Response(status_code=status.HTTP_204_NO_CONTENT)

    async def groups_group_id_activities_activity_id_settlements_delete(
        self, group_id: str, activity_id: str
    ) -> None:
        await self.settlement_service.clear_settlements(
            group_id=group_id, activity_id=activity_id
        )
        return Response(status_code=status.HTTP_204_NO_CONTENT)
