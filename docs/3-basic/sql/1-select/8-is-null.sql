-- IS NULL / IS NOT NULL
-- 担当者が未割り当てのタスクを取得する
SELECT id, title, status
FROM tasks
WHERE assignee_id IS NULL;
