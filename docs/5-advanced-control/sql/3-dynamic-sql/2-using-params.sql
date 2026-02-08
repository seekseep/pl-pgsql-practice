-- ============================================================
-- USING によるパラメータバインド
-- ============================================================
-- SQL インジェクション対策のため、値は USING で渡す

DO $$
DECLARE
    v_rec RECORD;
BEGIN
    FOR v_rec IN
        EXECUTE 'SELECT id, last_name, first_name FROM employees WHERE department_id = $1 AND is_active = $2 ORDER BY id LIMIT 5'
        USING 2, TRUE
    LOOP
        RAISE NOTICE 'ID=%, % %', v_rec.id, v_rec.last_name, v_rec.first_name;
    END LOOP;
END;
$$;
