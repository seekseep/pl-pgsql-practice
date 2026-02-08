-- ============================================================
-- 基本的な関数 (引数なし)
-- ============================================================

CREATE OR REPLACE FUNCTION count_active_employees()
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM employees
    WHERE is_active = TRUE;

    RETURN v_count;
END;
$$;

-- 実行テスト
DO $$
BEGIN
    RAISE NOTICE 'アクティブ従業員数: %', count_active_employees();
END;
$$;
