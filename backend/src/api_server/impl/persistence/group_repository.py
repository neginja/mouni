import uuid

from api_server.models.group import Group


class GroupRepository:
    def __init__(self, db) -> None:
        self.db = db

    def create(self, group: Group) -> Group:
        new_id = str(uuid.uuid4())

        query = """
        INSERT INTO groups (id, name)
        VALUES (?, ?)
        """
        self.db.execute(query, (new_id, group.name))
        self.db.commit()

        group.id = new_id
        return group

    def get(self, group_id: str) -> Group | None:
        cursor = self.db.execute("SELECT * FROM groups WHERE id = ?", (group_id,))
        row = cursor.fetchone()
        if not row:
            return None

        return Group.model_validate(dict(row))

    def list(self) -> list[Group]:
        cursor = self.db.execute("SELECT * FROM groups ORDER BY created_at DESC")
        groups = []
        rows = cursor.fetchall()
        for row in rows:
            groups.append(Group.model_validate(dict(row)))
        return groups

    def update(self, group_id: str, group: Group) -> Group | None:
        # Only updating name here; extend as needed
        query = """
        UPDATE groups SET name = ?, updated_at=CURRENT_TIMESTAMP WHERE id = ?
        """
        self.db.execute(query, (group.name, group_id))
        self.db.commit()
        return self.get(group_id)

    def delete(self, group_id: str):
        self.db.execute("DELETE FROM groups WHERE id = ?", (group_id,))
        self.db.commit()
