-- INSERT ... ON CONFLICT (UPSERT)
-- 既にメンバーがいる場合は何もしない (UNIQUE 制約を利用)
INSERT INTO project_members (project_id, employee_id, role, joined_at)
VALUES (1, 1, 'reviewer', CURRENT_DATE)
ON CONFLICT (project_id, employee_id) DO NOTHING;

-- 既にメンバーがいる場合は役割を更新する
INSERT INTO project_members (project_id, employee_id, role, joined_at)
VALUES (1, 1, 'manager', CURRENT_DATE)
ON CONFLICT (project_id, employee_id)
DO UPDATE SET
    role = EXCLUDED.role,
    updated_at = CURRENT_TIMESTAMP;
