-- ============================================================
-- CONTINUE (スキップ)
-- ============================================================
-- CONTINUE で現在の反復を飛ばして次へ進む

DO $$
DECLARE
    v_rec RECORD;
BEGIN
    FOR v_rec IN
        SELECT id, last_name, first_name, is_active
        FROM employees
        ORDER BY id
        LIMIT 20
    LOOP
        -- 退職済みの従業員はスキップ
        CONTINUE WHEN NOT v_rec.is_active;

        RAISE NOTICE '[在籍] ID=%, % %', v_rec.id, v_rec.last_name, v_rec.first_name;
    END LOOP;
END;
$$;
