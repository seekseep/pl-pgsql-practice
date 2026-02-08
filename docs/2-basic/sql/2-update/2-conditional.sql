-- 条件付き UPDATE
-- 退職処理: 特定の従業員を非アクティブにする
UPDATE employees
SET
    is_active = FALSE,
    updated_at = CURRENT_TIMESTAMP
WHERE id = 5;
