-- WHERE による絞り込み
-- 在籍中の従業員のみ取得する
SELECT id, last_name, first_name, email
FROM employees
WHERE is_active = TRUE;
