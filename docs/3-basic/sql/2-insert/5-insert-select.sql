-- INSERT ... SELECT
-- active プロジェクトの最初のメンバーを新規プロジェクトにもコピーする
INSERT INTO project_members (project_id, employee_id, role, joined_at)
SELECT
    21,
    pm.employee_id,
    'member',
    CURRENT_DATE
FROM project_members pm
INNER JOIN projects p ON pm.project_id = p.id
WHERE p.status = 'active'
  AND pm.project_id = (
      SELECT id FROM projects WHERE status = 'active' ORDER BY id LIMIT 1
  )
ON CONFLICT (project_id, employee_id) DO NOTHING;
