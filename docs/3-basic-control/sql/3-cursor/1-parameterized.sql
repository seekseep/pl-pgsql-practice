-- ============================================================
-- パラメータ付きカーソル
-- ============================================================
-- カーソル宣言時に引数を定義し、OPEN 時に値を渡す

DO $$
DECLARE
    cur_tasks CURSOR (p_project_id INT, p_status VARCHAR) FOR
        SELECT t.id, t.title, t.priority,
               e.last_name || ' ' || e.first_name AS assignee_name
        FROM tasks t
        LEFT JOIN employees e ON t.assignee_id = e.id
        WHERE t.project_id = p_project_id
          AND t.status = p_status
        ORDER BY t.id;
    v_rec RECORD;
BEGIN
    OPEN cur_tasks(1, 'todo');

    LOOP
        FETCH cur_tasks INTO v_rec;
        EXIT WHEN NOT FOUND;

        RAISE NOTICE '[%] % (担当: %)',
            v_rec.priority, v_rec.title, COALESCE(v_rec.assignee_name, '未割当');
    END LOOP;

    CLOSE cur_tasks;
END;
$$;
