-- ============================================================
-- FOUND 変数
-- ============================================================
-- 直前の SQL 文が行を返したかどうかを真偽値で保持する特殊変数
-- ※ IF 文は次の 1-condition で学ぶため、ここでは値の確認のみ

DO $$
DECLARE
    v_name employees.last_name%TYPE;
BEGIN
    -- 存在する従業員を検索
    SELECT last_name INTO v_name
    FROM employees
    WHERE id = 1;

    RAISE NOTICE '検索結果: %, FOUND: %', v_name, FOUND;

    -- 存在しない従業員を検索
    SELECT last_name INTO v_name
    FROM employees
    WHERE id = 9999;

    RAISE NOTICE '検索結果: %, FOUND: %', v_name, FOUND;
END;
$$;
