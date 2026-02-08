-- ============================================================
-- NULL チェック
-- ============================================================
-- IS NULL / IS NOT NULL で NULL を判定する

DO $$
DECLARE
    v_task tasks%ROWTYPE;
BEGIN
    SELECT * INTO v_task FROM tasks WHERE id = 1;

    IF v_task.assignee_id IS NULL THEN
        RAISE NOTICE 'タスク「%」は担当者未割り当てです', v_task.title;
    ELSE
        RAISE NOTICE 'タスク「%」の担当者ID: %', v_task.title, v_task.assignee_id;
    END IF;

    IF v_task.due_date IS NOT NULL AND v_task.due_date < CURRENT_DATE THEN
        RAISE NOTICE '※ このタスクは期限切れです (期限: %)', v_task.due_date;
    END IF;
END;
$$;
