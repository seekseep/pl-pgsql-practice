-- 集約 + CASE (クロス集計)
-- プロジェクトごとにステータス別のタスク数を集計する
SELECT
    p.name AS project_name,
    COUNT(*) AS total,
    COUNT(CASE WHEN t.status = 'todo' THEN 1 END) AS todo,
    COUNT(CASE WHEN t.status = 'in_progress' THEN 1 END) AS in_progress,
    COUNT(CASE WHEN t.status = 'in_review' THEN 1 END) AS in_review,
    COUNT(CASE WHEN t.status = 'done' THEN 1 END) AS done
FROM projects p
INNER JOIN tasks t ON p.id = t.project_id
GROUP BY p.id, p.name
ORDER BY p.name;
