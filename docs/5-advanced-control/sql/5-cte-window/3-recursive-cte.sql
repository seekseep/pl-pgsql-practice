-- ============================================================
-- 再帰 CTE (WITH RECURSIVE)
-- ============================================================

-- 月初の日付列を生成する例
DO $$
DECLARE
    v_rec RECORD;
BEGIN
    FOR v_rec IN
        WITH RECURSIVE month_series AS (
            SELECT DATE '2025-01-01' AS month_start
            UNION ALL
            SELECT (month_start + INTERVAL '1 month')::DATE
            FROM month_series
            WHERE month_start < DATE '2025-06-01'
        )
        SELECT
            ms.month_start,
            COUNT(t.id) AS task_count
        FROM month_series ms
        LEFT JOIN tasks t
            ON t.created_at >= ms.month_start
           AND t.created_at <  (ms.month_start + INTERVAL '1 month')
        GROUP BY ms.month_start
        ORDER BY ms.month_start
    LOOP
        RAISE NOTICE '%: タスク % 件',
            TO_CHAR(v_rec.month_start, 'YYYY-MM'), v_rec.task_count;
    END LOOP;
END;
$$;
