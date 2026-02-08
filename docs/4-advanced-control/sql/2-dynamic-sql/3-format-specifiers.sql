-- ============================================================
-- format() の書式指定子
-- ============================================================
-- %I = 識別子 (テーブル名、カラム名) → 自動クォート
-- %L = リテラル (値) → 自動エスケープ
-- %s = そのまま (信頼できる文字列のみ)

DO $$
DECLARE
    v_rec RECORD;
    v_sql TEXT;
BEGIN
    v_sql := format(
        'SELECT id, %I, %I FROM %I WHERE %I = %L ORDER BY id LIMIT 3',
        'last_name', 'first_name',
        'employees',
        'is_active',
        'true'
    );

    RAISE NOTICE 'SQL: %', v_sql;

    FOR v_rec IN EXECUTE v_sql LOOP
        RAISE NOTICE 'ID=%, % %', v_rec.id, v_rec.last_name, v_rec.first_name;
    END LOOP;
END;
$$;
