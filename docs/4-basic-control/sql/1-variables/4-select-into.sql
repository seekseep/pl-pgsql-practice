-- ============================================================
-- SELECT INTO による変数への代入
-- ============================================================
-- クエリ結果を変数に格納する

DO $$
DECLARE
    v_dept_name VARCHAR(100);
    v_emp_count INT;
BEGIN
    -- 部署名を取得
    SELECT name INTO v_dept_name
    FROM departments
    WHERE id = 1;

    -- その部署の従業員数を取得
    SELECT COUNT(*) INTO v_emp_count
    FROM employees
    WHERE department_id = 1;

    RAISE NOTICE '部署: %, 従業員数: %', v_dept_name, v_emp_count;
END;
$$;
