-- ============================================================
-- IF ... THEN ... END IF
-- ============================================================
-- 条件が TRUE のときだけ処理を実行する

DO $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count FROM employees WHERE is_active = TRUE;

    IF v_count > 50 THEN
        RAISE NOTICE 'アクティブ従業員は % 人です (50人超)', v_count;
    END IF;
END;
$$;
