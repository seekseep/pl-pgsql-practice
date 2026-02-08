-- デフォルト値の利用
-- DEFAULT を明示的に指定して INSERT する
INSERT INTO tasks (project_id, title, status, priority)
VALUES (1, '確認テスト用タスク', DEFAULT, DEFAULT)
RETURNING id, title, status, priority;
