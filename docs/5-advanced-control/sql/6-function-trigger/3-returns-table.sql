-- ============================================================
-- RETURNS TABLE 関数
-- ============================================================

CREATE OR REPLACE FUNCTION get_department_members(p_dept_id INT)
RETURNS TABLE (
    employee_id   INT,
    full_name     TEXT,
    email         VARCHAR,
    hire_date     DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.id,
        e.last_name || ' ' || e.first_name,
        e.email,
        e.hire_date
    FROM employees e
    WHERE e.department_id = p_dept_id
      AND e.is_active = TRUE
    ORDER BY e.hire_date;
END;
$$;

-- 実行テスト
DO $$
DECLARE
    v_rec RECORD;
BEGIN
    RAISE NOTICE '=== 部署ID=1 のメンバー ===';
    FOR v_rec IN SELECT * FROM get_department_members(1)
    LOOP
        RAISE NOTICE '  [%] % (%) 入社: %',
            v_rec.employee_id, v_rec.full_name,
            v_rec.email, v_rec.hire_date;
    END LOOP;
END;
$$;
