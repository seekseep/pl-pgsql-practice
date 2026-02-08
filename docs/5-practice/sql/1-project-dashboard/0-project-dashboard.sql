-- ============================================================
-- 課題 1: プロジェクトダッシュボード
-- ============================================================
-- 全プロジェクトの進捗状況を一覧で返す関数
-- 学習ポイント: RETURNS TABLE, CTE, COALESCE, RETURN QUERY

CREATE OR REPLACE FUNCTION get_project_dashboard(
    p_status VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    project_name  VARCHAR,
    status        VARCHAR,
    member_count  BIGINT,
    total_tasks   BIGINT,
    done_tasks    BIGINT,
    progress_pct  INT,
    overdue_tasks BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    WITH task_stats AS (
        SELECT
            t.project_id,
            COUNT(*)                                        AS total,
            COUNT(*) FILTER (WHERE t.status = 'done')       AS done,
            COUNT(*) FILTER (WHERE t.status != 'done'
                              AND t.due_date < CURRENT_DATE) AS overdue
        FROM tasks t
        GROUP BY t.project_id
    ),
    member_stats AS (
        SELECT pm.project_id, COUNT(*) AS cnt
        FROM project_members pm
        GROUP BY pm.project_id
    )
    SELECT
        p.name,
        p.status,
        COALESCE(ms.cnt, 0),
        COALESCE(ts.total, 0),
        COALESCE(ts.done, 0),
        CASE
            WHEN COALESCE(ts.total, 0) = 0 THEN 0
            ELSE (COALESCE(ts.done, 0) * 100 / ts.total)::INT
        END,
        COALESCE(ts.overdue, 0)
    FROM projects p
    LEFT JOIN task_stats   ts ON p.id = ts.project_id
    LEFT JOIN member_stats ms ON p.id = ms.project_id
    WHERE p_status IS NULL OR p.status = p_status
    ORDER BY
        CASE
            WHEN COALESCE(ts.total, 0) = 0 THEN 0
            ELSE (COALESCE(ts.done, 0) * 100 / ts.total)
        END DESC;
END;
$$;

-- 実行テスト: 全プロジェクト
DO $$
DECLARE
    v_rec RECORD;
BEGIN
    RAISE NOTICE '=== 全プロジェクト ===';
    FOR v_rec IN SELECT * FROM get_project_dashboard()
    LOOP
        RAISE NOTICE '% [%] メンバー:% タスク:%/% (進捗:%) 期限切れ:%',
            v_rec.project_name, v_rec.status,
            v_rec.member_count, v_rec.done_tasks, v_rec.total_tasks,
            v_rec.progress_pct || '%', v_rec.overdue_tasks;
    END LOOP;
END;
$$;

-- 実行テスト: active のみ
DO $$
DECLARE
    v_rec RECORD;
BEGIN
    RAISE NOTICE '=== active プロジェクト ===';
    FOR v_rec IN SELECT * FROM get_project_dashboard('active')
    LOOP
        RAISE NOTICE '% メンバー:% 進捗:%',
            v_rec.project_name, v_rec.member_count, v_rec.progress_pct || '%';
    END LOOP;
END;
$$;

-- クリーンアップ
DROP FUNCTION IF EXISTS get_project_dashboard(VARCHAR);
