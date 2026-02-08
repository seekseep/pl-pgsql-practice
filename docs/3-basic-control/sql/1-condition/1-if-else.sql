-- ============================================================
-- IF ... THEN ... ELSE
-- ============================================================
-- 条件が TRUE / FALSE の二択で分岐する

DO $$
DECLARE
    v_employee employees%ROWTYPE;
BEGIN
    SELECT * INTO v_employee FROM employees WHERE id = 1;

    IF v_employee.is_active THEN
        RAISE NOTICE '% % は在籍中です', v_employee.last_name, v_employee.first_name;
    ELSE
        RAISE NOTICE '% % は退職済みです', v_employee.last_name, v_employee.first_name;
    END IF;
END;
$$;
