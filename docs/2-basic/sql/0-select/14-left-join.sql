-- LEFT JOIN
-- プロジェクトごとのタスク数を取得する (タスクがないプロジェクトも含む)
SELECT
    p.id,
    p.name AS project_name,
    COUNT(t.id) AS task_count
FROM projects p
LEFT JOIN tasks t ON p.id = t.project_id
GROUP BY p.id, p.name
ORDER BY task_count DESC;
