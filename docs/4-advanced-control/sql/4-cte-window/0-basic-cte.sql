-- ============================================================
-- 基本的な CTE (WITH 句)
-- ============================================================

DO $$
DECLARE
    v_rec RECORD;
BEGIN
    FOR v_rec IN
        WITH dept_stats AS (
            SELECT
                d.id,
                d.name,
                COUNT(e.id) AS emp_count
            FROM departments d
            LEFT JOIN employees e ON d.id = e.department_id
            GROUP BY d.id, d.name
        )
        SELECT * FROM dept_stats ORDER BY emp_count DESC
    LOOP
        RAISE NOTICE '部署: % (% 人)', v_rec.name, v_rec.emp_count;
    END LOOP;
END;
$$;
