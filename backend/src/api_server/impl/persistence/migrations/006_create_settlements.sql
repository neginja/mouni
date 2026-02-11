CREATE TABLE IF NOT EXISTS settlements (
    id TEXT PRIMARY KEY,
    activity_id TEXT NOT NULL,
    from_member TEXT NOT NULL,
    to_member TEXT NOT NULL,
    amount REAL NOT NULL CHECK (amount > 0),
    currency TEXT NOT NULL,
    paid INTEGER NOT NULL DEFAULT 0,
    paid_on TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (activity_id) REFERENCES activities(id) ON DELETE CASCADE,
    FOREIGN KEY (from_member) REFERENCES members(id) ON DELETE CASCADE,
    FOREIGN KEY (to_member) REFERENCES members(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_settlements_activity_id ON settlements(activity_id);
CREATE INDEX IF NOT EXISTS idx_settlements_from_member ON settlements(from_member);
CREATE INDEX IF NOT EXISTS idx_settlements_to_member ON settlements(to_member);
