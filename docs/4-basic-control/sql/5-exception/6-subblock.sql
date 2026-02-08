-- ============================================================
-- サブブロックでの例外処理
-- ============================================================
-- ループ内で BEGIN...EXCEPTION を使い、エラーが起きても他の反復は続行する

DO $$
DECLARE
    v_rec RECORD;
BEGIN
    FOR v_rec IN SELECT id, name FROM departments ORDER BY id LOOP
        BEGIN
            IF v_rec.id = 3 THEN
                RAISE EXCEPTION '部署 % でエラー発生', v_rec.name;
            END IF;

            RAISE NOTICE '部署 % の処理完了', v_rec.name;
        EXCEPTION
            WHEN raise_exception THEN
                RAISE NOTICE '※ 部署 % の処理でエラー: % (スキップ)', v_rec.name, SQLERRM;
        END;
    END LOOP;

    RAISE NOTICE '全部署の処理が完了しました';
END;
$$;
