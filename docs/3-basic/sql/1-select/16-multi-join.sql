-- 複数テーブルの JOIN
-- プロジェクトメンバーの一覧を取得する
SELECT
    e.last_name || ' ' || e.first_name AS employee_name,
    p.name AS project_name,
    pm.role
FROM project_members pm
INNER JOIN employees e ON pm.employee_id = e.id
INNER JOIN projects p ON pm.project_id = p.id
ORDER BY p.name, pm.role;
