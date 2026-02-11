CREATE TABLE IF NOT EXISTS members (
    id TEXT PRIMARY KEY,                   -- UUID or unique string
    group_id TEXT NOT NULL,
    name TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE,
    UNIQUE (group_id, name)
);
CREATE INDEX IF NOT EXISTS idx_members_group_id ON members(group_id);
