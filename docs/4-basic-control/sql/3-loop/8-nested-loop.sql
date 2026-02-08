-- ============================================================
-- ネストしたループ
-- ============================================================
-- ループの中にループを入れて、組み合わせを処理する

DO $$
DECLARE
    v_project RECORD;
    v_task    RECORD;
BEGIN
    FOR v_project IN
        SELECT id, name FROM projects WHERE status = 'active' ORDER BY id LIMIT 3
    LOOP
        RAISE NOTICE '=== プロジェクト: % ===', v_project.name;

        FOR v_task IN
            SELECT id, title, status, priority
            FROM tasks
            WHERE project_id = v_project.id
            ORDER BY id
            LIMIT 5
        LOOP
            RAISE NOTICE '  [%/%] %', v_task.status, v_task.priority, v_task.title;
        END LOOP;
    END LOOP;
END;
$$;
