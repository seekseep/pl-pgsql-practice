-- ============================================================
-- FOR ループ (整数範囲)
-- ============================================================
-- FOR i IN 開始..終了 で整数を順に回す

DO $$
BEGIN
    -- 1 から 5 まで
    FOR i IN 1..5 LOOP
        RAISE NOTICE 'i = %', i;
    END LOOP;

    -- REVERSE で降順
    RAISE NOTICE '--- 降順 ---';
    FOR i IN REVERSE 5..1 LOOP
        RAISE NOTICE 'i = %', i;
    END LOOP;

    -- BY でステップ指定
    RAISE NOTICE '--- 2刻み ---';
    FOR i IN 1..10 BY 2 LOOP
        RAISE NOTICE 'i = %', i;
    END LOOP;
END;
$$;
