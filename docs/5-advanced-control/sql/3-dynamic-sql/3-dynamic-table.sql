-- ============================================================
-- テーブル名を動的に指定
-- ============================================================
-- テーブル名は USING で渡せないため format() + %I を使う

DO $$
DECLARE
    v_table_name TEXT;
    v_count      INT;
    v_tables     TEXT[] := ARRAY['departments', 'employees', 'projects', 'tasks'];
BEGIN
    FOREACH v_table_name IN ARRAY v_tables LOOP
        EXECUTE format('SELECT COUNT(*) FROM %I', v_table_name) INTO v_count;
        RAISE NOTICE '% : % 件', v_table_name, v_count;
    END LOOP;
END;
$$;
