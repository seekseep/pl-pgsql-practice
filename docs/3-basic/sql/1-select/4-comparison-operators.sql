-- 比較演算子
-- 2025年7月以降に入社した従業員を取得する
SELECT id, last_name, first_name, hire_date
FROM employees
WHERE hire_date >= '2025-07-01';
