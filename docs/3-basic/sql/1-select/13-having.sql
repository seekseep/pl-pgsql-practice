-- HAVING による集約結果の絞り込み
-- 従業員が 10 人以上の部署を取得する
SELECT department_id, COUNT(*) AS employee_count
FROM employees
GROUP BY department_id
HAVING COUNT(*) >= 10;
