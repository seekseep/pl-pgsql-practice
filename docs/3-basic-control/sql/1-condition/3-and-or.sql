-- ============================================================
-- 複合条件 (AND / OR)
-- ============================================================
-- AND: 両方 TRUE で成立、OR: どちらかが TRUE で成立

DO $$
DECLARE
    v_emp employees%ROWTYPE;
BEGIN
    SELECT * INTO v_emp FROM employees WHERE id = 1;

    IF v_emp.is_active AND v_emp.hire_date < '2025-07-01' THEN
        RAISE NOTICE '% % はベテラン社員です', v_emp.last_name, v_emp.first_name;
    END IF;

    IF NOT v_emp.is_active OR v_emp.hire_date >= '2026-01-01' THEN
        RAISE NOTICE '% % は退職済みまたは新入社員です', v_emp.last_name, v_emp.first_name;
    ELSE
        RAISE NOTICE '% % は在籍中の既存社員です', v_emp.last_name, v_emp.first_name;
    END IF;
END;
$$;
