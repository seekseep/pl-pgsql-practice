-- ORDER BY によるソート
-- 従業員を入社日の新しい順に取得する
SELECT id, last_name, first_name, hire_date
FROM employees
ORDER BY hire_date DESC;
