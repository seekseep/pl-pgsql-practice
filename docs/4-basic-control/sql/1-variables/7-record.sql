-- ============================================================
-- RECORD 型
-- ============================================================
-- 任意のクエリ結果を格納する汎用型
-- %ROWTYPE と違い、どんなクエリ結果でも受け取れる

DO $$
DECLARE
    v_rec RECORD;
BEGIN
    SELECT
        d.name AS dept_name,
        COUNT(e.id) AS emp_count
    INTO v_rec
    FROM departments d
    LEFT JOIN employees e ON d.id = e.department_id
    WHERE d.id = 2
    GROUP BY d.name;

    RAISE NOTICE '部署: %, 人数: %', v_rec.dept_name, v_rec.emp_count;
END;
$$;
