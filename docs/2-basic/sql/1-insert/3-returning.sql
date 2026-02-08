-- INSERT ... RETURNING
-- 追加したレコードの ID を確認する (PostgreSQL 固有)
INSERT INTO departments (name)
VALUES ('研究開発部')
RETURNING id, name;
