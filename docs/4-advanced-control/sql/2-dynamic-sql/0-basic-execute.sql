-- ============================================================
-- EXECUTE の基本
-- ============================================================
-- SQL 文を文字列として組み立てて実行する

DO $$
DECLARE
    v_count INT;
BEGIN
    EXECUTE 'SELECT COUNT(*) FROM employees' INTO v_count;
    RAISE NOTICE '従業員数: %', v_count;
END;
$$;
