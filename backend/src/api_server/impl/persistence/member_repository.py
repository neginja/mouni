import uuid

from api_server.models.member import Member


class MemberRepository:
    def __init__(self, db) -> None:
        self.db = db

    def create(self, member: Member, group_id: str) -> Member:
        new_id = str(uuid.uuid4())
        query = """
        INSERT INTO members (id, group_id, name)
        VALUES (?, ?, ?)
        """
        self.db.execute(query, (new_id, group_id, member.name))
        self.db.commit()
        member.id = new_id
        return member

    def get(self, group_id: str, member_id: str) -> Member | None:
        cursor = self.db.execute(
            "SELECT * FROM members WHERE id = ? AND group_id = ?",
            (
                member_id,
                group_id,
            ),
        )
        row = cursor.fetchone()
        if not row:
            return None

        return Member.model_validate(dict(row))

    def list_by_group(self, group_id: str) -> list[Member]:
        cursor = self.db.execute(
            "SELECT * FROM members WHERE group_id = ? ORDER BY name ASC", (group_id,)
        )
        return [Member.model_validate(dict(row)) for row in cursor.fetchall()]

    def update(self, group_id: str, member_id: str, member: Member) -> Member | None:
        query = """
        UPDATE members SET name = ?, updated_at=CURRENT_TIMESTAMP WHERE id = ? AND group_id = ?
        """
        self.db.execute(
            query,
            (
                member.name,
                member_id,
                group_id,
            ),
        )
        self.db.commit()
        return self.get(group_id=group_id, member_id=member_id)

    def delete(self, group_id: str, member_id: str):
        self.db.execute(
            "DELETE FROM members WHERE id = ? AND group_id = ?",
            (
                member_id,
                group_id,
            ),
        )
        self.db.commit()
