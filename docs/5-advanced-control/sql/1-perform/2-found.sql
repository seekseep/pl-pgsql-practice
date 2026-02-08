-- ============================================================
-- PERFORM + FOUND
-- ============================================================
-- PERFORM 後に FOUND でレコードの存在を確認する

DO $$
BEGIN
    PERFORM 1 FROM employees WHERE id = 1;

    IF FOUND THEN
        RAISE NOTICE 'ID=1 の従業員は存在します';
    ELSE
        RAISE NOTICE 'ID=1 の従業員は存在しません';
    END IF;
END;
$$;
