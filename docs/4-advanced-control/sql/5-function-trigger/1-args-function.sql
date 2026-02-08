-- ============================================================
-- 引数付き関数
-- ============================================================

CREATE OR REPLACE FUNCTION get_department_employee_count(
    p_dept_id INT
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM employees
    WHERE department_id = p_dept_id
      AND is_active = TRUE;

    RETURN v_count;
END;
$$;

-- 実行テスト
DO $$
DECLARE
    v_rec RECORD;
BEGIN
    FOR v_rec IN SELECT id, name FROM departments ORDER BY id
    LOOP
        RAISE NOTICE '%: % 人',
            v_rec.name, get_department_employee_count(v_rec.id);
    END LOOP;
END;
$$;
