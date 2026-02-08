-- ============================================================
-- UPDATE ... RETURNING INTO
-- ============================================================
-- 更新後の値を変数に取得する

DO $$
DECLARE
    v_task_id INT;
    v_new_status VARCHAR(20);
BEGIN
    UPDATE tasks
    SET status = 'in_progress', updated_at = CURRENT_TIMESTAMP
    WHERE id = (SELECT id FROM tasks WHERE status = 'todo' ORDER BY id LIMIT 1)
    RETURNING id, status INTO v_task_id, v_new_status;

    IF FOUND THEN
        RAISE NOTICE 'タスクID=% のステータスを % に変更しました', v_task_id, v_new_status;
    ELSE
        RAISE NOTICE '対象のタスクが見つかりません';
    END IF;
END;
$$;
