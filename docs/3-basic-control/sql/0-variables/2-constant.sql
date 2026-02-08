-- ============================================================
-- 定数 (CONSTANT)
-- ============================================================
-- CONSTANT を付けると再代入できない変数になる

DO $$
DECLARE
    C_TAX_RATE CONSTANT NUMERIC := 0.10;
    v_price    NUMERIC := 1000;
    v_total    NUMERIC;
BEGIN
    v_total := v_price * (1 + C_TAX_RATE);
    RAISE NOTICE '税込価格: %', v_total;
END;
$$;
