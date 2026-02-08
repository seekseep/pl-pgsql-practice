-- ============================================================
-- SUM / AVG ウィンドウ関数 (累計・移動平均)
-- ============================================================

DO $$
DECLARE
    v_rec RECORD;
BEGIN
    RAISE NOTICE '=== 部署別従業員の累計と移動平均 ===';
    FOR v_rec IN
        WITH dept_hire AS (
            SELECT
                d.name AS dept_name,
                DATE_TRUNC('month', e.hire_date)::DATE AS hire_month,
                COUNT(*) AS hire_count
            FROM employees e
            INNER JOIN departments d ON e.department_id = d.id
            GROUP BY d.name, DATE_TRUNC('month', e.hire_date)
        )
        SELECT
            dept_name,
            hire_month,
            hire_count,
            SUM(hire_count) OVER (
                PARTITION BY dept_name
                ORDER BY hire_month
                ROWS UNBOUNDED PRECEDING
            ) AS cumulative_total,
            ROUND(AVG(hire_count) OVER (
                PARTITION BY dept_name
                ORDER BY hire_month
                ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
            ), 1) AS moving_avg_3
        FROM dept_hire
        ORDER BY dept_name, hire_month
    LOOP
        RAISE NOTICE '% | % | 入社: % | 累計: % | 移動平均: %',
            v_rec.dept_name, v_rec.hire_month,
            v_rec.hire_count, v_rec.cumulative_total, v_rec.moving_avg_3;
    END LOOP;
END;
$$;
