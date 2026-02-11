import uuid
from datetime import datetime

from api_server.models.expense import Expense
from api_server.models.expense_involved import ExpenseInvolved


class ExpenseRepository:
    def __init__(self, db):
        self.db = db

    def create(self, activity_id: str, expense: Expense) -> Expense:
        query = """
        INSERT INTO expenses (id, activity_id, description, amount, currency, paid_by, date)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        """
        new_id = str(uuid.uuid4())
        self.db.execute(
            query,
            (
                new_id,
                activity_id,
                expense.description,
                expense.amount,
                expense.currency,
                expense.paid_by,
                expense.var_date.isoformat()
                if hasattr(expense.var_date, "isoformat")
                else expense.var_date,
            ),
        )
        self.db.commit()

        expense.id = new_id
        return expense

    def get(self, activity_id: str, expense_id: str) -> Expense | None:
        cursor = self.db.execute(
            "SELECT * FROM expenses WHERE id = ? AND activity_id=?",
            (
                expense_id,
                activity_id,
            ),
        )
        row = cursor.fetchone()
        if not row:
            return None

        involved_cursor = self.db.execute(
            "SELECT member_id FROM expense_involved WHERE expense_id = ?", (expense_id,)
        )
        involved = [
            ExpenseInvolved.model_validate(dict(row))
            for row in involved_cursor.fetchall()
        ]

        # Map DB row to dict with field aliases & types for Pydantic model
        expense_data = {
            "id": row["id"],
            "description": row["description"],
            "amount": row["amount"],
            "currency": row["currency"],
            "paidBy": row["paid_by"],
            "involved": involved,
            "date": datetime.fromisoformat(row["date"])
            if isinstance(row["date"], str)
            else row["date"],
        }

        return Expense.model_validate(expense_data)

    def list_by_activity(self, activity_id: str) -> list[Expense]:
        cursor = self.db.execute(
            "SELECT * FROM expenses WHERE activity_id = ? ORDER BY date DESC",
            (activity_id,),
        )
        expenses = []
        rows = cursor.fetchall()

        for row in rows:
            expense_id = row["id"]
            involved_cursor = self.db.execute(
                "SELECT * FROM expense_involved WHERE expense_id = ?",
                (expense_id,),
            )
            involved = [
                ExpenseInvolved.model_validate(dict(row))
                for row in involved_cursor.fetchall()
            ]

            expense_data = {
                "id": row["id"],
                "description": row["description"],
                "amount": row["amount"],
                "currency": row["currency"],
                "paidBy": row["paid_by"],
                "involved": involved,
                "date": datetime.fromisoformat(row["date"])
                if isinstance(row["date"], str)
                else row["date"],
            }
            expenses.append(Expense.model_validate(expense_data))

        return expenses

    def update(
        self, activity_id: str, expense_id: str, expense: Expense
    ) -> Expense | None:
        query = """
        UPDATE expenses SET description = ?, amount = ?, currency = ?, paid_by = ?, date = ?, updated_at=CURRENT_TIMESTAMP WHERE id = ? AND activity_id=?
        """
        self.db.execute(
            query,
            (
                expense.description,
                expense.amount,
                expense.currency,
                expense.paid_by,
                expense.var_date.isoformat()
                if hasattr(expense.var_date, "isoformat")
                else expense.var_date,
                expense_id,
                activity_id,
            ),
        )
        self.db.commit()
        return self.get(activity_id=activity_id, expense_id=expense_id)

    def delete(self, activity_id: str, expense_id: str) -> None:
        self.db.execute(
            "DELETE FROM expenses WHERE id = ? AND activity_id = ?",
            (
                expense_id,
                activity_id,
            ),
        )
        self.db.commit()
