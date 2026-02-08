-- 複数カラムの UPDATE
-- 従業員の部署異動を行う
UPDATE employees
SET
    department_id = 3,
    updated_at = CURRENT_TIMESTAMP
WHERE id = 1;
