-- DELETE ... RETURNING
-- 削除したレコードの内容を確認する (PostgreSQL 固有)
DELETE FROM job_logs
WHERE id = 2
RETURNING id, job_id, status, message;
