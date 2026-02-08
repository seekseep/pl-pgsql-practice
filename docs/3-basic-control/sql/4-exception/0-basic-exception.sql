-- ============================================================
-- 基本的な例外処理
-- ============================================================
-- BEGIN ... EXCEPTION WHEN ... THEN でエラーをキャッチする

DO $$
DECLARE
    v_result INT;
BEGIN
    v_result := 10 / 0;
    RAISE NOTICE '結果: %', v_result;
EXCEPTION
    WHEN division_by_zero THEN
        RAISE NOTICE 'エラー: ゼロで割ることはできません';
END;
$$;
