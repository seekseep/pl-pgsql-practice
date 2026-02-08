-- ============================================================
-- 課題 0: 部署別レポート
-- ============================================================
-- 指定した部署の詳細レポートを出力する関数
-- 学習ポイント: SELECT INTO, IF, FOUND, RAISE NOTICE

CREATE OR REPLACE FUNCTION report_department(p_dept_id INT)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_dept_name     VARCHAR;
    v_total_emp     INT;
    v_active_emp    INT;
    v_project_count INT;
    v_open_tasks    INT;
    v_overdue_tasks INT;
BEGIN
    -- 部署の存在チェック
    SELECT name INTO v_dept_name
    FROM departments
    WHERE id = p_dept_id;

    IF NOT FOUND THEN
        RAISE NOTICE '部署ID=% は存在しません', p_dept_id;
        RETURN;
    END IF;

    -- 従業員数
    SELECT
        COUNT(*),
        COUNT(*) FILTER (WHERE is_active = TRUE)
    INTO v_total_emp, v_active_emp
    FROM employees
    WHERE department_id = p_dept_id;

    -- 参加プロジェクト数
    SELECT COUNT(DISTINCT pm.project_id) INTO v_project_count
    FROM project_members pm
    INNER JOIN employees e ON pm.employee_id = e.id
    WHERE e.department_id = p_dept_id;

    -- 未完了タスク数
    SELECT COUNT(*) INTO v_open_tasks
    FROM tasks t
    INNER JOIN employees e ON t.assignee_id = e.id
    WHERE e.department_id = p_dept_id
      AND t.status != 'done';

    -- 期限切れタスク数
    SELECT COUNT(*) INTO v_overdue_tasks
    FROM tasks t
    INNER JOIN employees e ON t.assignee_id = e.id
    WHERE e.department_id = p_dept_id
      AND t.status != 'done'
      AND t.due_date < CURRENT_DATE;

    -- レポート出力
    RAISE NOTICE '========================================';
    RAISE NOTICE '部署レポート: %', v_dept_name;
    RAISE NOTICE '========================================';
    RAISE NOTICE '従業員数: % 人 (在籍: % 人)', v_total_emp, v_active_emp;
    RAISE NOTICE '参加プロジェクト数: %', v_project_count;
    RAISE NOTICE '未完了タスク数: %', v_open_tasks;
    RAISE NOTICE '期限切れタスク数: %', v_overdue_tasks;
END;
$$;

-- 実行テスト
SELECT report_department(1);
SELECT report_department(2);
SELECT report_department(9999);

-- クリーンアップ
DROP FUNCTION IF EXISTS report_department(INT);
