-- サブクエリ (WHERE 句)
-- 開発部に所属する従業員を取得する
SELECT id, last_name, first_name
FROM employees
WHERE department_id = (
    SELECT id FROM departments WHERE name = '開発部'
);
