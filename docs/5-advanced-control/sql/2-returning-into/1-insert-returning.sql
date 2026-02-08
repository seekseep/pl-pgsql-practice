-- ============================================================
-- INSERT ... RETURNING INTO
-- ============================================================
-- 追加したレコードの自動採番 ID を変数に取得する

DO $$
DECLARE
    v_new_id INT;
    v_name   VARCHAR(100);
BEGIN
    INSERT INTO departments (name)
    VALUES ('RETURNING テスト部')
    RETURNING id, name INTO v_new_id, v_name;

    RAISE NOTICE '追加成功: ID=%, 名前=%', v_new_id, v_name;

    DELETE FROM departments WHERE id = v_new_id;
END;
$$;
