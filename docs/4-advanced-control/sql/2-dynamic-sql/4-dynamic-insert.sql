-- ============================================================
-- 動的 SQL で INSERT
-- ============================================================
-- format() で INSERT 文を組み立てて実行する

DO $$
DECLARE
    v_new_id INT;
BEGIN
    EXECUTE format(
        'INSERT INTO %I (name) VALUES (%L) RETURNING id',
        'departments', '動的SQL部'
    ) INTO v_new_id;

    RAISE NOTICE '動的 INSERT 成功: ID=%', v_new_id;

    EXECUTE 'DELETE FROM departments WHERE id = $1' USING v_new_id;
END;
$$;
