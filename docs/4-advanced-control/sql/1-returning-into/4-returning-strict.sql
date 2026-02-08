-- ============================================================
-- RETURNING INTO STRICT
-- ============================================================
-- STRICT を付けると 0 行または 2 行以上で例外が発生する

DO $$
DECLARE
    v_task tasks%ROWTYPE;
BEGIN
    UPDATE tasks
    SET updated_at = CURRENT_TIMESTAMP
    WHERE id = 99999
    RETURNING * INTO STRICT v_task;

    RAISE NOTICE 'タスク: %', v_task.title;
EXCEPTION
    WHEN no_data_found THEN
        RAISE NOTICE '更新対象が見つかりません (0行)';
    WHEN too_many_rows THEN
        RAISE NOTICE '更新対象が複数あります';
END;
$$;
