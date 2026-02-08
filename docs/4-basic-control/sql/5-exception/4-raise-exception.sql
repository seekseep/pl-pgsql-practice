-- ============================================================
-- RAISE EXCEPTION (カスタムエラー)
-- ============================================================
-- RAISE EXCEPTION で独自のエラーを発生させる

DO $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM project_members
    WHERE project_id = 1;

    IF v_count > 100 THEN
        RAISE EXCEPTION 'プロジェクトメンバーが上限 (100人) を超えています: % 人', v_count;
    END IF;

    RAISE NOTICE 'メンバー数: % 人 (上限内)', v_count;
EXCEPTION
    WHEN raise_exception THEN
        RAISE NOTICE 'バリデーションエラー: %', SQLERRM;
END;
$$;
