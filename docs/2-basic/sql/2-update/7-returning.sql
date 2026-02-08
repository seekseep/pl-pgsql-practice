-- UPDATE ... RETURNING
-- 更新結果を確認しながら UPDATE する (PostgreSQL 固有)
UPDATE employees
SET
    is_active = FALSE,
    updated_at = CURRENT_TIMESTAMP
WHERE id = 10
RETURNING id, last_name, first_name, is_active;
