-- ============================================================
-- ROW_NUMBER() ウィンドウ関数
-- ============================================================

DO $$
DECLARE
    v_rec RECORD;
BEGIN
    FOR v_rec IN
        SELECT
            ROW_NUMBER() OVER (
                PARTITION BY department_id
                ORDER BY hire_date
            ) AS row_num,
            last_name || ' ' || first_name AS full_name,
            department_id,
            hire_date
        FROM employees
        WHERE is_active = TRUE
        ORDER BY department_id, row_num
    LOOP
        IF v_rec.row_num = 1 THEN
            RAISE NOTICE '--- 部署ID: % ---', v_rec.department_id;
        END IF;
        RAISE NOTICE '  #%: % (入社: %)',
            v_rec.row_num, v_rec.full_name, v_rec.hire_date;
    END LOOP;
END;
$$;
