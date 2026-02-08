-- ============================================================
-- SQLSTATE と SQLERRM
-- ============================================================
-- WHEN OTHERS で全ての例外をキャッチし、詳細を取得する

DO $$
DECLARE
    v_emp employees%ROWTYPE;
BEGIN
    SELECT * INTO STRICT v_emp FROM employees WHERE id = 99999;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'SQLSTATE: %', SQLSTATE;
        RAISE NOTICE 'エラーメッセージ: %', SQLERRM;
END;
$$;
