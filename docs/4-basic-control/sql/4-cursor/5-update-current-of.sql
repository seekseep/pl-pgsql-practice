-- ============================================================
-- UPDATE WHERE CURRENT OF
-- ============================================================
-- カーソルが指している行を直接更新する

DO $$
DECLARE
    cur_tasks CURSOR FOR
        SELECT id, title, priority
        FROM tasks
        WHERE status = 'todo' AND priority = 'low'
        FOR UPDATE;
    v_rec   RECORD;
    v_count INT := 0;
BEGIN
    OPEN cur_tasks;

    LOOP
        FETCH cur_tasks INTO v_rec;
        EXIT WHEN NOT FOUND;

        UPDATE tasks
        SET priority = 'medium', updated_at = CURRENT_TIMESTAMP
        WHERE CURRENT OF cur_tasks;

        v_count := v_count + 1;
    END LOOP;

    CLOSE cur_tasks;
    RAISE NOTICE '% 件のタスクの優先度を medium に変更しました', v_count;
END;
$$;
