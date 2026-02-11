import uuid

from api_server.models.settlement import Settlement


class SettlementRepository:
    def __init__(self, db) -> None:
        self.db = db

    def create(self, activity_id: str, settlement: Settlement) -> Settlement:
        new_id = str(uuid.uuid4())
        query = """
        INSERT INTO settlements (id, activity_id, from_member, to_member, amount, currency, paid)
        VALUES (?, ?, ?, ?, ?, ?, 0)
        """
        self.db.execute(
            query,
            (
                new_id,
                activity_id,
                settlement.from_member,
                settlement.to_member,
                settlement.amount,
                settlement.currency,
            ),
        )
        self.db.commit()

        settlement.id = new_id
        return Settlement(
            id=new_id,
            from_member=settlement.from_member,
            to_member=settlement.to_member,
            amount=settlement.amount,
            currency=settlement.currency,
            paid=False,
        )

    def get(self, activity_id: str, settlement_id: str) -> Settlement | None:
        cursor = self.db.execute(
            "SELECT * FROM settlements WHERE id = ? AND activity_id=?",
            (
                settlement_id,
                activity_id,
            ),
        )
        row = cursor.fetchone()
        if not row:
            return None

        dict_row = dict(row)
        dict_row["paid"] = True if dict_row["paid"] > 0 else False
        return Settlement.model_validate(dict_row)

    def list_by_activity(self, activity_id: str) -> list[Settlement]:
        cursor = self.db.execute(
            "SELECT * FROM settlements WHERE activity_id = ? ORDER BY amount DESC",
            (activity_id,),
        )
        rows = cursor.fetchall()

        models = []
        for row in rows:
            dict_row = dict(row)
            dict_row["paid"] = True if dict_row["paid"] > 0 else False
            models.append(Settlement.model_validate(dict_row))

        return models

    def patch_paid_status(
        self, activity_id: str, settlement_id: str, paid: bool
    ) -> Settlement | None:
        query = """
        UPDATE settlements SET paid=?, paid_on=CURRENT_TIMESTAMP, updated_at=CURRENT_TIMESTAMP WHERE id = ? AND activity_id = ?
        """
        self.db.execute(
            query,
            (
                int(paid),
                settlement_id,
                activity_id,
            ),
        )
        self.db.commit()
        return self.get(activity_id, settlement_id)

    def delete(self, activity_id: str, settlement_id: str):
        self.db.execute(
            "DELETE FROM settlements WHERE id = ? AND activity_id = ?",
            (
                settlement_id,
                activity_id,
            ),
        )
        self.db.commit()

    def delete_all_for_activity(self, activity_id: str) -> None:
        self.db.execute(
            "DELETE FROM settlements WHERE activity_id = ?",
            (activity_id,),
        )
        self.db.commit()
