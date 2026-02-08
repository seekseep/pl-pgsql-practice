-- 日付条件による DELETE
-- 2025年1月より前のジョブログを削除する
DELETE FROM job_logs
WHERE started_at < '2025-01-01';
