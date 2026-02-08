-- 集約関数 (COUNT, SUM, AVG, MAX, MIN)
-- 従業員の総数を取得する
SELECT COUNT(*) AS total_employees FROM employees;

-- 部署ごとの従業員数を取得する
SELECT department_id, COUNT(*) AS employee_count
FROM employees
GROUP BY department_id;
