-- ============================================================
-- FOR ループ (動的 SQL)
-- ============================================================
-- EXECUTE で文字列として組み立てた SQL の結果をループする

DO $$
DECLARE
    v_rec   RECORD;
    v_query TEXT;
BEGIN
    v_query := 'SELECT id, name, status FROM projects WHERE status = $1 ORDER BY id';

    FOR v_rec IN EXECUTE v_query USING 'active'
    LOOP
        RAISE NOTICE 'プロジェクト[%]: % (%)', v_rec.id, v_rec.name, v_rec.status;
    END LOOP;
END;
$$;
