-- ============================================================
-- jsonb_each でキーと値をループ
-- ============================================================

DO $$
DECLARE
    v_config JSONB := '{
        "max_retries": 3,
        "timeout_sec": 30,
        "batch_size": 100,
        "log_level": "info"
    }';
    v_key   TEXT;
    v_value JSONB;
BEGIN
    FOR v_key, v_value IN SELECT * FROM jsonb_each(v_config)
    LOOP
        RAISE NOTICE '設定: % = %', v_key, v_value;
    END LOOP;
END;
$$;
