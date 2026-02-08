-- EXISTS を使った DELETE
-- archived プロジェクトの全タスクを削除する
DELETE FROM tasks
WHERE EXISTS (
    SELECT 1 FROM projects p
    WHERE p.id = tasks.project_id
      AND p.status = 'archived'
);
