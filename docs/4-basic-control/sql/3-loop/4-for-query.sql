-- ============================================================
-- FOR ループ (クエリ結果)
-- ============================================================
-- SELECT の結果を 1 行ずつ RECORD に格納して処理する

DO $$
DECLARE
    v_rec RECORD;
BEGIN
    FOR v_rec IN
        SELECT d.name AS dept_name, COUNT(e.id) AS emp_count
        FROM departments d
        LEFT JOIN employees e ON d.id = e.department_id
        GROUP BY d.id, d.name
        ORDER BY d.id
    LOOP
        RAISE NOTICE '% : % 人', v_rec.dept_name, v_rec.emp_count;
    END LOOP;
END;
$$;
