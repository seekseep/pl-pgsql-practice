-- ============================================================
-- EXECUTE ... INTO STRICT
-- ============================================================
-- 結果が正確に 1 行であることを保証する

DO $$
DECLARE
    v_name VARCHAR(100);
BEGIN
    EXECUTE 'SELECT name FROM departments WHERE id = $1'
    INTO STRICT v_name
    USING 1;

    RAISE NOTICE '部署名: %', v_name;
EXCEPTION
    WHEN no_data_found THEN
        RAISE NOTICE '該当なし';
    WHEN too_many_rows THEN
        RAISE NOTICE '複数件該当';
END;
$$;
