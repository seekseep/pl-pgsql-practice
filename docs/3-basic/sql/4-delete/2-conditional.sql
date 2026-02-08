-- 条件付き DELETE
-- 失敗したジョブログを削除する
DELETE FROM job_logs
WHERE status = 'failure';
