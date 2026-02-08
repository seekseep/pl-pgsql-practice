-- EXISTS
-- プロジェクトに 1 つ以上参加している従業員を取得する
SELECT e.id, e.last_name, e.first_name
FROM employees e
WHERE EXISTS (
    SELECT 1 FROM project_members pm WHERE pm.employee_id = e.id
);
