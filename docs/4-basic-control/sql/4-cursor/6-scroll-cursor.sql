-- ============================================================
-- SCROLL カーソル
-- ============================================================
-- SCROLL を付けると前後に移動できるカーソルになる

DO $$
DECLARE
    cur SCROLL CURSOR FOR
        SELECT id, name FROM departments ORDER BY id;
    v_rec RECORD;
BEGIN
    OPEN cur;

    RAISE NOTICE '--- 順方向 ---';
    FOR i IN 1..3 LOOP
        FETCH NEXT FROM cur INTO v_rec;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE '→ % : %', v_rec.id, v_rec.name;
    END LOOP;

    RAISE NOTICE '--- 逆方向 ---';
    FOR i IN 1..2 LOOP
        FETCH PRIOR FROM cur INTO v_rec;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE '← % : %', v_rec.id, v_rec.name;
    END LOOP;

    FETCH LAST FROM cur INTO v_rec;
    RAISE NOTICE '最後: % : %', v_rec.id, v_rec.name;

    FETCH FIRST FROM cur INTO v_rec;
    RAISE NOTICE '最初: % : %', v_rec.id, v_rec.name;

    CLOSE cur;
END;
$$;
