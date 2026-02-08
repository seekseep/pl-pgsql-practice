-- ============================================================
-- SETOF RECORD を返す関数
-- ============================================================

CREATE OR REPLACE FUNCTION get_project_summary()
RETURNS TABLE (
    project_name VARCHAR,
    status       VARCHAR,
    member_count BIGINT,
    task_count   BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.name,
        p.status,
        COUNT(DISTINCT pm.employee_id),
        COUNT(DISTINCT t.id)
    FROM projects p
    LEFT JOIN project_members pm ON p.id = pm.project_id
    LEFT JOIN tasks t ON p.id = t.project_id
    GROUP BY p.id, p.name, p.status
    ORDER BY p.id;
END;
$$;

-- 実行テスト
DO $$
DECLARE
    v_rec RECORD;
BEGIN
    FOR v_rec IN SELECT * FROM get_project_summary()
    LOOP
        RAISE NOTICE '% [%] メンバー: % タスク: %',
            v_rec.project_name, v_rec.status,
            v_rec.member_count, v_rec.task_count;
    END LOOP;
END;
$$;
