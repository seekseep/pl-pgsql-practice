-- CASE を使った条件付き UPDATE
-- タスクの優先度を一括で見直す
UPDATE tasks
SET
    priority = CASE
        WHEN priority = 'urgent' THEN 'high'
        WHEN priority = 'low'    THEN 'medium'
        ELSE priority
    END,
    updated_at = CURRENT_TIMESTAMP
WHERE priority IN ('urgent', 'low');
