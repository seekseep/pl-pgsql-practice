-- ============================================================
-- 課題 3: タスク自動割り当て
-- ============================================================
-- 未割り当てタスクをプロジェクトメンバーにラウンドロビンで割り当て
-- 学習ポイント: 配列, array_agg, ラウンドロビン, FOR ループ

CREATE OR REPLACE FUNCTION auto_assign_tasks(p_project_id INT)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_project_name VARCHAR;
    v_members      INT[];
    v_member_count INT;
    v_task         RECORD;
    v_idx          INT := 0;
    v_assigned     INT := 0;
    v_assignee_name TEXT;
BEGIN
    -- プロジェクトの存在チェック
    SELECT name INTO v_project_name
    FROM projects
    WHERE id = p_project_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'プロジェクトID=% は存在しません', p_project_id;
    END IF;

    -- アクティブなメンバーの ID を配列に取得
    SELECT array_agg(pm.employee_id ORDER BY pm.employee_id)
    INTO v_members
    FROM project_members pm
    INNER JOIN employees e ON pm.employee_id = e.id
    WHERE pm.project_id = p_project_id
      AND e.is_active = TRUE;

    IF v_members IS NULL THEN
        RAISE EXCEPTION 'プロジェクト「%」にアクティブなメンバーがいません',
            v_project_name;
    END IF;

    v_member_count := array_length(v_members, 1);
    RAISE NOTICE '=== プロジェクト「%」のタスク自動割り当て ===', v_project_name;
    RAISE NOTICE 'メンバー数: %', v_member_count;

    -- 未割り当てタスクを優先度順にループ
    FOR v_task IN
        SELECT id, title, priority
        FROM tasks
        WHERE project_id = p_project_id
          AND assignee_id IS NULL
        ORDER BY
            CASE priority
                WHEN 'urgent' THEN 1
                WHEN 'high'   THEN 2
                WHEN 'medium' THEN 3
                WHEN 'low'    THEN 4
            END
    LOOP
        -- ラウンドロビンで割り当て
        UPDATE tasks
        SET assignee_id = v_members[1 + (v_idx % v_member_count)],
            updated_at = CURRENT_TIMESTAMP
        WHERE id = v_task.id;

        -- 割り当て先の名前を取得
        SELECT last_name || ' ' || first_name INTO v_assignee_name
        FROM employees
        WHERE id = v_members[1 + (v_idx % v_member_count)];

        RAISE NOTICE '  [%] % → %',
            v_task.priority, v_task.title, v_assignee_name;

        v_idx := v_idx + 1;
        v_assigned := v_assigned + 1;
    END LOOP;

    IF v_assigned = 0 THEN
        RAISE NOTICE '未割り当てのタスクはありません';
    ELSE
        RAISE NOTICE '合計 % 件のタスクを割り当てました', v_assigned;
    END IF;
END;
$$;

-- 実行テスト
SELECT auto_assign_tasks(1);

-- クリーンアップ
DROP FUNCTION IF EXISTS auto_assign_tasks(INT);
