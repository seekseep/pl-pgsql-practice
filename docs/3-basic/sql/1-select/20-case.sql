-- CASE 式
-- タスクの優先度を日本語で表示する
SELECT
    id,
    title,
    CASE priority
        WHEN 'urgent' THEN '緊急'
        WHEN 'high'   THEN '高'
        WHEN 'medium' THEN '中'
        WHEN 'low'    THEN '低'
    END AS priority_label,
    status
FROM tasks
ORDER BY
    CASE priority
        WHEN 'urgent' THEN 1
        WHEN 'high'   THEN 2
        WHEN 'medium' THEN 3
        WHEN 'low'    THEN 4
    END;
