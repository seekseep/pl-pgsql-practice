-- ============================================================
-- 基本的なカーソル (OPEN → FETCH → CLOSE)
-- ============================================================
-- カーソルを使うと大量データを 1 行ずつ処理できる

DO $$
DECLARE
    cur_employees CURSOR FOR
        SELECT id, last_name, first_name, email
        FROM employees
        WHERE is_active = TRUE
        ORDER BY id;
    v_rec   RECORD;
    v_count INT := 0;
BEGIN
    OPEN cur_employees;

    LOOP
        FETCH cur_employees INTO v_rec;
        EXIT WHEN NOT FOUND;

        v_count := v_count + 1;
        IF v_count <= 5 THEN
            RAISE NOTICE '% % (%)', v_rec.last_name, v_rec.first_name, v_rec.email;
        END IF;
    END LOOP;

    CLOSE cur_employees;
    RAISE NOTICE '合計: % 人', v_count;
END;
$$;
