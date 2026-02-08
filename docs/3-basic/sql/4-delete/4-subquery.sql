-- サブクエリを使った DELETE
-- 無効化されたジョブのログを全て削除する
DELETE FROM job_logs
WHERE job_id IN (
    SELECT id FROM jobs WHERE is_enabled = FALSE
);
