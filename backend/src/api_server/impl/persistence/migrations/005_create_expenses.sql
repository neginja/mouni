CREATE TABLE IF NOT EXISTS expenses (
    id TEXT PRIMARY KEY,
    activity_id TEXT NOT NULL,
    description TEXT NOT NULL,
    amount REAL NOT NULL CHECK (amount >= 0),
    currency TEXT NOT NULL,                -- ISO currency code (e.g., USD, JPY)
    paid_by TEXT NOT NULL,                 -- member ID who paid
    date TEXT NOT NULL,                    -- ISO 8601 datetime string
    category TEXT,                         -- nullable category column
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (activity_id) REFERENCES activities(id) ON DELETE RESTRICT,
    FOREIGN KEY (paid_by) REFERENCES members(id) ON DELETE RESTRICT
);
CREATE INDEX IF NOT EXISTS idx_expenses_activity_id ON expenses(activity_id);
CREATE INDEX IF NOT EXISTS idx_expenses_paid_by ON expenses(paid_by);
