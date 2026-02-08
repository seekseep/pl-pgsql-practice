-- ============================================================
-- 動的 SQL で条件を組み立てる
-- ============================================================
-- 検索条件を動的に構築するパターン

DO $$
DECLARE
    v_sql    TEXT;
    v_rec    RECORD;
    -- 検索パラメータ (NULL = 条件なし)
    p_status     VARCHAR := 'active';
    p_start_date DATE    := '2025-01-01';
    p_end_date   DATE    := NULL;
BEGIN
    v_sql := 'SELECT id, name, status, start_date FROM projects WHERE 1=1';

    IF p_status IS NOT NULL THEN
        v_sql := v_sql || format(' AND status = %L', p_status);
    END IF;

    IF p_start_date IS NOT NULL THEN
        v_sql := v_sql || format(' AND start_date >= %L', p_start_date);
    END IF;

    IF p_end_date IS NOT NULL THEN
        v_sql := v_sql || format(' AND end_date <= %L', p_end_date);
    END IF;

    v_sql := v_sql || ' ORDER BY id';

    RAISE NOTICE '実行SQL: %', v_sql;

    FOR v_rec IN EXECUTE v_sql LOOP
        RAISE NOTICE '[%] % (開始: %)', v_rec.status, v_rec.name, v_rec.start_date;
    END LOOP;
END;
$$;
