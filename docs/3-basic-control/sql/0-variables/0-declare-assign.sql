-- ============================================================
-- 変数の宣言と代入
-- ============================================================
-- DECLARE で変数を宣言し、:= で値を代入する

DO $$
DECLARE
    v_name    VARCHAR(100);
    v_count   INT;
    v_active  BOOLEAN;
BEGIN
    v_name   := '開発部';
    v_count  := 42;
    v_active := TRUE;

    RAISE NOTICE '部署名: %, 人数: %, アクティブ: %', v_name, v_count, v_active;
END;
$$;
