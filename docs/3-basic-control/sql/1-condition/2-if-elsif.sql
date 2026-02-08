-- ============================================================
-- IF ... ELSIF ... ELSE
-- ============================================================
-- 3 つ以上の条件で分岐する

DO $$
DECLARE
    v_task_count INT;
    v_project    projects%ROWTYPE;
BEGIN
    SELECT * INTO v_project FROM projects WHERE id = 1;

    SELECT COUNT(*) INTO v_task_count
    FROM tasks WHERE project_id = v_project.id;

    IF v_task_count = 0 THEN
        RAISE NOTICE 'プロジェクト「%」にはタスクがありません', v_project.name;
    ELSIF v_task_count <= 10 THEN
        RAISE NOTICE 'プロジェクト「%」のタスク数は少なめです (% 件)', v_project.name, v_task_count;
    ELSIF v_task_count <= 20 THEN
        RAISE NOTICE 'プロジェクト「%」のタスク数は普通です (% 件)', v_project.name, v_task_count;
    ELSE
        RAISE NOTICE 'プロジェクト「%」のタスク数は多いです (% 件)', v_project.name, v_task_count;
    END IF;
END;
$$;
