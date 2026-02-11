from api_server.models.expense_involved import ExpenseInvolved


class ExpenseInvolvedRepository:
    def __init__(self, db):
        self.db = db

    def add_involved(
        self, member_id: str, expense_id: str, share: float
    ) -> ExpenseInvolved:
        query = """
        INSERT INTO expense_involved (expense_id, member_id, share)
        VALUES (?, ?, ?)
        """
        self.db.execute(query, (expense_id, member_id, share))
        self.db.commit()
        return ExpenseInvolved.model_validate(
            {"expense_id": expense_id, "member_id": member_id, "share": share}
        )

    def list_by_expense(self, expense_id: str) -> list[ExpenseInvolved]:
        cursor = self.db.execute(
            "SELECT * FROM expense_involved WHERE expense_id = ? ORDER BY share DESC",
            (expense_id,),
        )
        return [ExpenseInvolved.model_validate(dict(row)) for row in cursor.fetchall()]

    def remove_involved(self, expense_id: str, member_id: str):
        query = """
        DELETE FROM expense_involved WHERE expense_id = ? AND member_id = ?
        """
        self.db.execute(query, (expense_id, member_id))
        self.db.commit()

    def remove_all_by_expense(self, expense_id: str) -> None:
        self.db.execute(
            "DELETE FROM expense_involved WHERE expense_id = ?", (expense_id,)
        )
        self.db.commit()
