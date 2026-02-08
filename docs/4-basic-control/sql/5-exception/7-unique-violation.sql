-- ============================================================
-- UNIQUE 制約違反のハンドリング
-- ============================================================
-- unique_violation で重複エラーをキャッチする

DO $$
BEGIN
    -- 既に存在するメールアドレスで INSERT を試みる
    INSERT INTO employees (department_id, last_name, first_name, email, hire_date)
    VALUES (1, 'テスト', '太郎', 'emp0001@example.com', CURRENT_DATE);

    RAISE NOTICE '従業員を追加しました';
EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'エラー: そのメールアドレスは既に使われています';
END;
$$;
