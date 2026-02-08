-- ============================================================
-- 存在チェックに PERFORM を使う
-- ============================================================
-- レコードがなければ処理を分岐するパターン

DO $$
DECLARE
    v_dept_id INT := 999;
BEGIN
    PERFORM 1 FROM departments WHERE id = v_dept_id;

    IF NOT FOUND THEN
        RAISE NOTICE '部署ID=% は存在しません。新規作成します。', v_dept_id;
    END IF;
END;
$$;
