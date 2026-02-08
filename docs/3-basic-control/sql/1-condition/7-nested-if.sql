-- ============================================================
-- ネストした IF
-- ============================================================
-- IF の中にさらに IF を書いて、段階的に判定する
-- ※ LOOP は次の 2-loop で学ぶため、ここでは 1 レコードで示す

DO $$
DECLARE
    v_emp  employees%ROWTYPE;
    v_dept departments%ROWTYPE;
BEGIN
    SELECT * INTO v_emp FROM employees WHERE id = 1;
    SELECT * INTO v_dept FROM departments WHERE id = v_emp.department_id;

    IF v_emp.is_active THEN
        IF v_emp.hire_date < CURRENT_DATE - INTERVAL '1 year' THEN
            RAISE NOTICE '[在籍/経験1年超] % % (%)', v_emp.last_name, v_emp.first_name, v_dept.name;
        ELSE
            RAISE NOTICE '[在籍/新人] % % (%)', v_emp.last_name, v_emp.first_name, v_dept.name;
        END IF;
    ELSE
        RAISE NOTICE '[退職済] % %', v_emp.last_name, v_emp.first_name;
    END IF;
END;
$$;
