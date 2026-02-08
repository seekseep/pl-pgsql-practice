-- 単純な UPDATE
-- 部署名を変更する
UPDATE departments
SET name = '第一開発部', updated_at = CURRENT_TIMESTAMP
WHERE id = 2;
