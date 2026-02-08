-- IN による複数値指定
-- ステータスが active または planning のプロジェクトを取得する
SELECT id, name, status
FROM projects
WHERE status IN ('active', 'planning');
