-- ============================================================
-- RETURNING * INTO で行全体を取得
-- ============================================================
-- %ROWTYPE 変数に行をまるごと格納する

DO $$
DECLARE
    v_dept departments%ROWTYPE;
BEGIN
    INSERT INTO departments (name)
    VALUES ('行全体テスト部')
    RETURNING * INTO v_dept;

    RAISE NOTICE 'ID=%, 名前=%, 作成日時=%', v_dept.id, v_dept.name, v_dept.created_at;

    DELETE FROM departments WHERE id = v_dept.id;
END;
$$;
