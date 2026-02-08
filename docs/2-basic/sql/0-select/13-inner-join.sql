-- INNER JOIN
-- 従業員と所属部署名を結合して取得する
SELECT
    e.id,
    e.last_name,
    e.first_name,
    d.name AS department_name
FROM employees e
INNER JOIN departments d ON e.department_id = d.id;
