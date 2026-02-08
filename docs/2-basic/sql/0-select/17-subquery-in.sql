-- サブクエリ (IN)
-- active なプロジェクトに参加している従業員を取得する
SELECT DISTINCT e.id, e.last_name, e.first_name
FROM employees e
WHERE e.id IN (
    SELECT pm.employee_id
    FROM project_members pm
    INNER JOIN projects p ON pm.project_id = p.id
    WHERE p.status = 'active'
);
