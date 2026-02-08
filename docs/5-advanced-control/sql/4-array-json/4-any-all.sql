-- ============================================================
-- ANY / ALL で配列を条件に使う
-- ============================================================

DO $$
DECLARE
    v_target_depts INT[];
    v_rec RECORD;
BEGIN
    SELECT array_agg(id) INTO v_target_depts
    FROM departments
    WHERE name IN ('開発部', '営業部');

    RAISE NOTICE '対象部署ID: %', v_target_depts;

    FOR v_rec IN
        SELECT id, last_name, first_name, department_id
        FROM employees
        WHERE department_id = ANY(v_target_depts)
        ORDER BY id
        LIMIT 5
    LOOP
        RAISE NOTICE 'ID=%, % % (部署ID=%)', v_rec.id, v_rec.last_name, v_rec.first_name, v_rec.department_id;
    END LOOP;
END;
$$;
