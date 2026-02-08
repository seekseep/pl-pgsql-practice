-- ============================================================
-- WHILE ループ
-- ============================================================
-- 条件が TRUE の間だけ繰り返す

DO $$
DECLARE
    v_dept_id   INT := 1;
    v_dept_name VARCHAR(100);
    v_max_dept  INT;
BEGIN
    SELECT MAX(id) INTO v_max_dept FROM departments;

    WHILE v_dept_id <= v_max_dept LOOP
        SELECT name INTO v_dept_name FROM departments WHERE id = v_dept_id;

        IF FOUND THEN
            RAISE NOTICE '部署 %: %', v_dept_id, v_dept_name;
        END IF;

        v_dept_id := v_dept_id + 1;
    END LOOP;
END;
$$;
