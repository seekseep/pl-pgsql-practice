-- ============================================================
-- updated_at 自動更新トリガー
-- ============================================================

CREATE OR REPLACE FUNCTION trigger_set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- employees テーブルにトリガーを設定
DROP TRIGGER IF EXISTS trg_employees_updated_at ON employees;
CREATE TRIGGER trg_employees_updated_at
    BEFORE UPDATE ON employees
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_updated_at();

-- 動作確認
DO $$
DECLARE
    v_before TIMESTAMP;
    v_after  TIMESTAMP;
BEGIN
    SELECT updated_at INTO v_before FROM employees WHERE id = 1;
    RAISE NOTICE '更新前: %', v_before;

    PERFORM pg_sleep(0.1);

    UPDATE employees SET first_name = first_name WHERE id = 1;

    SELECT updated_at INTO v_after FROM employees WHERE id = 1;
    RAISE NOTICE '更新後: %', v_after;
    RAISE NOTICE 'updated_at が自動更新されました: %', v_after > v_before;
END;
$$;
