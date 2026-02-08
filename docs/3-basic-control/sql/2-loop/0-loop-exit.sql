-- ============================================================
-- 基本 LOOP (無限ループ + EXIT)
-- ============================================================
-- LOOP は EXIT で明示的に抜けるまで繰り返す

DO $$
DECLARE
    v_counter INT := 0;
BEGIN
    LOOP
        v_counter := v_counter + 1;
        EXIT WHEN v_counter > 5;
        RAISE NOTICE 'カウンター: %', v_counter;
    END LOOP;
    RAISE NOTICE 'ループ終了 (最終値: %)', v_counter;
END;
$$;
