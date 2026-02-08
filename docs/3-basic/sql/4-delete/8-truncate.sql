-- TRUNCATE (全件削除)
-- テーブルの全レコードを高速に削除する
-- ※ 注意: WHERE 句は使えず、ロールバックも難しい
-- TRUNCATE TABLE job_logs;

-- CASCADE 付きで関連テーブルも含めて全削除する場合:
-- TRUNCATE TABLE projects CASCADE;
