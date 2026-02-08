-- 複数行の UPDATE
-- 完了済みプロジェクトのステータスを archived に変更する
UPDATE projects
SET
    status = 'archived',
    updated_at = CURRENT_TIMESTAMP
WHERE status = 'completed';
