-- ============================================================
-- RANK / DENSE_RANK ウィンドウ関数
-- ============================================================

DO $$
DECLARE
    v_rec RECORD;
BEGIN
    RAISE NOTICE '=== 部署別タスク数ランキング ===';
    FOR v_rec IN
        WITH task_counts AS (
            SELECT
                e.department_id,
                d.name AS dept_name,
                e.id AS employee_id,
                e.last_name || ' ' || e.first_name AS full_name,
                COUNT(t.id) AS task_count
            FROM employees e
            INNER JOIN departments d ON e.department_id = d.id
            LEFT JOIN tasks t ON e.id = t.assignee_id
            WHERE e.is_active = TRUE
            GROUP BY e.department_id, d.name, e.id, e.last_name, e.first_name
        )
        SELECT
            dept_name,
            full_name,
            task_count,
            RANK() OVER (
                PARTITION BY department_id ORDER BY task_count DESC
            ) AS rank_num,
            DENSE_RANK() OVER (
                PARTITION BY department_id ORDER BY task_count DESC
            ) AS dense_rank_num
        FROM task_counts
        ORDER BY dept_name, rank_num
    LOOP
        RAISE NOTICE '% | % | タスク: % | RANK: % | DENSE_RANK: %',
            v_rec.dept_name, v_rec.full_name,
            v_rec.task_count, v_rec.rank_num, v_rec.dense_rank_num;
    END LOOP;
END;
$$;
