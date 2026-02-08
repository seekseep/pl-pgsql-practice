-- BETWEEN による範囲指定
-- 2025年上半期に入社した従業員を取得する
SELECT id, last_name, first_name, hire_date
FROM employees
WHERE hire_date BETWEEN '2025-01-01' AND '2025-06-30';
