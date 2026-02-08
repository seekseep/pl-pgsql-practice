-- ============================================================
-- FK 制約違反のハンドリング
-- ============================================================
-- foreign_key_violation で外部キーエラーをキャッチする

DO $$
BEGIN
    -- 存在しない部署 ID で INSERT を試みる
    INSERT INTO employees (department_id, last_name, first_name, email, hire_date)
    VALUES (9999, 'テスト', '次郎', 'test.jiro@example.com', CURRENT_DATE);

    RAISE NOTICE '従業員を追加しました';
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'エラー: 指定された部署が存在しません (department_id=9999)';
END;
$$;
