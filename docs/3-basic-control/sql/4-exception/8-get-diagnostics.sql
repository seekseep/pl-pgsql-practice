-- ============================================================
-- GET STACKED DIAGNOSTICS
-- ============================================================
-- 例外の詳細情報 (SQLSTATE, メッセージ, 詳細, ヒント, コンテキスト) を取得する

DO $$
DECLARE
    v_state   TEXT;
    v_msg     TEXT;
    v_detail  TEXT;
    v_hint    TEXT;
    v_context TEXT;
BEGIN
    INSERT INTO employees (department_id, last_name, first_name, email, hire_date)
    VALUES (9999, 'テスト', '三郎', 'test.saburo@example.com', CURRENT_DATE);
EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS
            v_state   = RETURNED_SQLSTATE,
            v_msg     = MESSAGE_TEXT,
            v_detail  = PG_EXCEPTION_DETAIL,
            v_hint    = PG_EXCEPTION_HINT,
            v_context = PG_EXCEPTION_CONTEXT;

        RAISE NOTICE 'SQLSTATE : %', v_state;
        RAISE NOTICE 'メッセージ : %', v_msg;
        RAISE NOTICE '詳細     : %', v_detail;
        RAISE NOTICE 'ヒント   : %', v_hint;
        RAISE NOTICE 'コンテキスト: %', v_context;
END;
$$;
