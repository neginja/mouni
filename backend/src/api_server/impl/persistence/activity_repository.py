import uuid

from api_server.models.activity import Activity


class ActivityRepository:
    def __init__(self, db):
        self.db = db

    def create(self, group_id: str, activity: Activity) -> Activity:
        new_id = str(uuid.uuid4())

        query = """
        INSERT INTO activities (id, group_id, name, start_date, end_date)
        VALUES (?, ?, ?, ?, ?)
        """
        self.db.execute(
            query,
            (
                new_id,
                group_id,
                activity.name,
                activity.start_date,
                activity.end_date,
            ),
        )
        self.db.commit()
        activity.id = new_id
        return activity

    def get(self, group_id: str, activity_id: str) -> Activity | None:
        cursor = self.db.execute(
            "SELECT * FROM activities WHERE id = ? AND group_id = ?",
            (
                activity_id,
                group_id,
            ),
        )
        row = cursor.fetchone()
        if not row:
            return None
        return Activity.model_validate(dict(row))

    def list_by_group(self, group_id: str) -> list[Activity]:
        cursor = self.db.execute(
            "SELECT * FROM activities WHERE group_id = ? ORDER BY start_date DESC, name ASC",
            (group_id,),
        )
        return [Activity.model_validate(dict(row)) for row in cursor.fetchall()]

    def update(
        self, group_id: str, activity_id: str, activity: Activity
    ) -> Activity | None:
        query = """
        UPDATE activities
        SET name = ?, start_date = ?, end_date = ?, updated_at=CURRENT_TIMESTAMP
        WHERE id = ? AND group_id = ?
        """
        self.db.execute(
            query,
            (
                activity.name,
                activity.start_date,
                activity.end_date,
                activity_id,
                group_id,
            ),
        )
        self.db.commit()
        return self.get(group_id=group_id, activity_id=activity_id)

    def delete(self, group_id: str, activity_id: str) -> None:
        self.db.execute(
            "DELETE FROM activities WHERE id = ? AND group_id = ?",
            (
                activity_id,
                group_id,
            ),
        )
        self.db.commit()
