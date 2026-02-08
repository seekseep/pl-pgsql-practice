-- ============================================================
-- 複数 CTE を組み合わせる
-- ============================================================

DO $$
DECLARE
    v_rec RECORD;
BEGIN
    FOR v_rec IN
        WITH dept_emp AS (
            SELECT department_id, COUNT(*) AS emp_count
            FROM employees
            WHERE is_active = TRUE
            GROUP BY department_id
        ),
        dept_tasks AS (
            SELECT e.department_id, COUNT(t.id) AS task_count
            FROM tasks t
            INNER JOIN employees e ON t.assignee_id = e.id
            WHERE t.status != 'done'
            GROUP BY e.department_id
        )
        SELECT
            d.name,
            COALESCE(de.emp_count, 0)  AS emp_count,
            COALESCE(dt.task_count, 0) AS task_count
        FROM departments d
        LEFT JOIN dept_emp   de ON d.id = de.department_id
        LEFT JOIN dept_tasks dt ON d.id = dt.department_id
        ORDER BY d.id
    LOOP
        RAISE NOTICE '%: 従業員 % 人, 未完了タスク % 件',
            v_rec.name, v_rec.emp_count, v_rec.task_count;
    END LOOP;
END;
$$;
