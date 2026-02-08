-- LIKE による部分一致検索
-- 姓が「田」で終わる従業員を取得する
SELECT id, last_name, first_name
FROM employees
WHERE last_name LIKE '%田';
