-- ============================================================
-- LAG / LEAD ウィンドウ関数
-- ============================================================

DO $$
DECLARE
    v_rec RECORD;
BEGIN
    RAISE NOTICE '=== プロジェクト開始日の前後比較 ===';
    FOR v_rec IN
        SELECT
            name,
            start_date,
            LAG(start_date)  OVER (ORDER BY start_date) AS prev_start,
            LEAD(start_date) OVER (ORDER BY start_date) AS next_start,
            start_date - LAG(start_date) OVER (ORDER BY start_date) AS days_since_prev
        FROM projects
        WHERE start_date IS NOT NULL
        ORDER BY start_date
    LOOP
        RAISE NOTICE '% (開始: %) | 前: % | 次: % | 前との差: % 日',
            v_rec.name, v_rec.start_date,
            COALESCE(v_rec.prev_start::TEXT, '-'),
            COALESCE(v_rec.next_start::TEXT, '-'),
            COALESCE(v_rec.days_since_prev::TEXT, '-');
    END LOOP;
END;
$$;
