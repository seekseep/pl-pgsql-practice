-- サブクエリを使った UPDATE
-- 開発部の全従業員のタスクを in_progress に変更する
UPDATE tasks
SET
    status = 'in_progress',
    updated_at = CURRENT_TIMESTAMP
WHERE assignee_id IN (
    SELECT id FROM employees
    WHERE department_id = (
        SELECT id FROM departments WHERE name = '開発部'
    )
)
AND status = 'todo';
