from functools import lru_cache
from sqlite3 import Connection

from api_server.impl.infra.db import get_db
from api_server.impl.persistence.activity_repository import ActivityRepository
from api_server.impl.persistence.expense_involved_repository import (
    ExpenseInvolvedRepository,
)
from api_server.impl.persistence.expense_repository import ExpenseRepository
from api_server.impl.persistence.group_repository import GroupRepository
from api_server.impl.persistence.member_repository import MemberRepository
from api_server.impl.persistence.settlement_repository import SettlementRepository
from api_server.impl.services.activity_service import ActivityService
from api_server.impl.services.expense_service import ExpenseService
from api_server.impl.services.group_service import GroupService
from api_server.impl.services.member_service import MemberService
from api_server.impl.services.settlement_service import SettlementService
from api_server.impl.utils import logger_from_env

logger = logger_from_env("dependencies")


@lru_cache()
def get_db_singleton() -> Connection:
    logger.debug("creating db dependency")
    return get_db()


@lru_cache()
def get_group_repository() -> GroupRepository:
    db = get_db_singleton()
    logger.debug("creating group repository dependency")
    return GroupRepository(db)


@lru_cache()
def get_member_repository() -> MemberRepository:
    db = get_db_singleton()
    logger.debug("creating member repository dependency")
    return MemberRepository(db)


@lru_cache()
def get_activity_repository() -> ActivityRepository:
    db = get_db_singleton()
    logger.debug("creating activitiy repository dependency")
    return ActivityRepository(db)


@lru_cache()
def get_expense_repository() -> ExpenseRepository:
    db = get_db_singleton()
    logger.debug("creating expense repository dependency")
    return ExpenseRepository(db)


@lru_cache()
def get_expense_involved_repository() -> ExpenseInvolvedRepository:
    db = get_db_singleton()
    logger.debug("creating expense involved repository dependency")
    return ExpenseInvolvedRepository(db)


@lru_cache()
def get_settlement_repository() -> SettlementRepository:
    db = get_db_singleton()
    logger.debug("creating settlement repository dependency")
    return SettlementRepository(db)


@lru_cache()
def get_group_service() -> GroupService:
    group_repo = get_group_repository()
    member_repo = get_member_repository()
    logger.debug("creating group service dependency")
    return GroupService(group_repo, member_repo)


@lru_cache()
def get_member_service() -> MemberService:
    repo = get_member_repository()
    logger.debug("creating member service dependency")
    return MemberService(repo)


@lru_cache()
def get_activity_service() -> ActivityService:
    activity_repo = get_activity_repository()
    settlement_repo = get_settlement_repository()
    logger.debug("creating activity service dependency")
    return ActivityService(
        activity_repo=activity_repo, settlements_repo=settlement_repo
    )


@lru_cache()
def get_expense_service() -> ExpenseService:
    expense_repo = get_expense_repository()
    expense_involve_repo = get_expense_involved_repository()
    settlement_repo = get_settlement_repository()
    logger.debug("creating expense service dependency")
    return ExpenseService(expense_repo, expense_involve_repo, settlement_repo)


@lru_cache()
def get_settlement_service() -> SettlementService:
    settlement_repo = get_settlement_repository()
    expense_repo = get_expense_repository()
    logger.debug("creating settlement service dependency")
    return SettlementService(settlement_repo, expense_repo)
