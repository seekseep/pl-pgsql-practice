-- LIMIT / OFFSET によるページング
-- 先頭 10 件を取得する
SELECT id, last_name, first_name
FROM employees
ORDER BY id
LIMIT 10;

-- 11件目から10件取得する (2ページ目)
SELECT id, last_name, first_name
FROM employees
ORDER BY id
LIMIT 10 OFFSET 10;
