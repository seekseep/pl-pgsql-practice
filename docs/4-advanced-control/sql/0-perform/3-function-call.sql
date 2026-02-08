-- ============================================================
-- PERFORM で関数を呼び出す
-- ============================================================
-- 戻り値が不要な関数呼び出しに使う

DO $$
DECLARE
    v_rec RECORD;
BEGIN
    FOR v_rec IN SELECT id, name FROM departments ORDER BY id LIMIT 3 LOOP
        PERFORM set_config('app.current_dept', v_rec.name, TRUE);
        RAISE NOTICE '処理中の部署: % (設定に保存)', v_rec.name;
    END LOOP;

    RAISE NOTICE '最後に設定された部署: %', current_setting('app.current_dept');
END;
$$;
