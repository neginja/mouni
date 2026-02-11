CREATE TABLE IF NOT EXISTS expense_involved (
    expense_id TEXT NOT NULL,
    member_id TEXT NOT NULL,
    share REAL NOT NULL CHECK (share >= 0),  -- fraction or amount member owes (optional for uneven splits)
    PRIMARY KEY (expense_id, member_id),
    FOREIGN KEY (expense_id) REFERENCES expenses(id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE RESTRICT
);
CREATE INDEX IF NOT EXISTS idx_expense_involved_expense_id ON expense_involved(expense_id);
CREATE INDEX IF NOT EXISTS idx_expense_involved_member_id ON expense_involved(member_id);

