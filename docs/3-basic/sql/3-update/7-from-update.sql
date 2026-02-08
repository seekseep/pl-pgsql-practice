-- FROM を使った UPDATE (PostgreSQL 固有)
-- active プロジェクトの未完了タスクの期限を 7 日延長する
UPDATE tasks
SET
    due_date = tasks.due_date + INTERVAL '7 days',
    updated_at = CURRENT_TIMESTAMP
FROM projects p
WHERE tasks.project_id = p.id
  AND p.status = 'active'
  AND tasks.status != 'done'
  AND tasks.due_date IS NOT NULL;
