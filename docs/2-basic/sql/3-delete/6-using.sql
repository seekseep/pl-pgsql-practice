-- USING を使った DELETE (PostgreSQL 固有)
-- completed プロジェクトのメンバーを削除する
DELETE FROM project_members
USING projects p
WHERE project_members.project_id = p.id
  AND p.status = 'completed';
