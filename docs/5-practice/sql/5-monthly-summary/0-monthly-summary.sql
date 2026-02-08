-- ============================================================
-- 課題 5: 月次サマリーレポート
-- ============================================================
-- 指定した年月の活動サマリーを JSON 形式で返す関数
-- 学習ポイント: RETURNS JSONB, jsonb_build_object, jsonb_agg, DATE_TRUNC

CREATE OR REPLACE FUNCTION get_monthly_summary(p_month DATE)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_start         DATE;
    v_end           DATE;
    v_new_emp       INT;
    v_active_proj   INT;
    v_tasks_created INT;
    v_tasks_done    INT;
    v_job_exec      INT;
    v_job_fail      INT;
    v_dept_breakdown JSONB;
BEGIN
    -- 月の範囲を計算
    v_start := DATE_TRUNC('month', p_month)::DATE;
    v_end   := (v_start + INTERVAL '1 month')::DATE;

    -- 新規入社者数
    SELECT COUNT(*) INTO v_new_emp
    FROM employees
    WHERE hire_date >= v_start AND hire_date < v_end;

    -- 稼働中プロジェクト数
    SELECT COUNT(*) INTO v_active_proj
    FROM projects
    WHERE status = 'active'
      AND (start_date IS NULL OR start_date < v_end)
      AND (end_date IS NULL OR end_date >= v_start);

    -- 作成されたタスク数
    SELECT COUNT(*) INTO v_tasks_created
    FROM tasks
    WHERE created_at >= v_start AND created_at < v_end;

    -- 完了したタスク数
    SELECT COUNT(*) INTO v_tasks_done
    FROM tasks
    WHERE status = 'done'
      AND updated_at >= v_start AND updated_at < v_end;

    -- ジョブ実行回数
    SELECT COUNT(*) INTO v_job_exec
    FROM job_logs
    WHERE started_at >= v_start AND started_at < v_end;

    -- ジョブ失敗回数
    SELECT COUNT(*) INTO v_job_fail
    FROM job_logs
    WHERE started_at >= v_start AND started_at < v_end
      AND status = 'failure';

    -- 部署ごとの従業員数
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'department', sub.name,
            'total',      sub.total,
            'active',     sub.active
        ) ORDER BY sub.name
    ), '[]'::JSONB)
    INTO v_dept_breakdown
    FROM (
        SELECT
            d.name,
            COUNT(e.id) AS total,
            COUNT(e.id) FILTER (WHERE e.is_active = TRUE) AS active
        FROM departments d
        LEFT JOIN employees e ON d.id = e.department_id
        GROUP BY d.id, d.name
    ) sub;

    -- JSON を構築して返す
    RETURN jsonb_build_object(
        'period',               TO_CHAR(v_start, 'YYYY-MM'),
        'new_employees',        v_new_emp,
        'active_projects',      v_active_proj,
        'tasks_created',        v_tasks_created,
        'tasks_completed',      v_tasks_done,
        'job_executions',       v_job_exec,
        'job_failures',         v_job_fail,
        'department_breakdown', v_dept_breakdown
    );
END;
$$;

-- 実行テスト
DO $$
DECLARE
    v_result JSONB;
BEGIN
    v_result := get_monthly_summary('2025-06-01');
    RAISE NOTICE '%', jsonb_pretty(v_result);
END;
$$;

-- クリーンアップ
DROP FUNCTION IF EXISTS get_monthly_summary(DATE);
