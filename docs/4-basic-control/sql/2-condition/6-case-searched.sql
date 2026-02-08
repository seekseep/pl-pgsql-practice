-- ============================================================
-- CASE 文 (検索 CASE)
-- ============================================================
-- WHEN に条件式を書いて分岐する (IF...ELSIF の代替)

DO $$
DECLARE
    v_done_rate  NUMERIC;
    v_project_id INT := 1;
    v_total      INT;
    v_done       INT;
BEGIN
    SELECT COUNT(*), COUNT(CASE WHEN status = 'done' THEN 1 END)
    INTO v_total, v_done
    FROM tasks
    WHERE project_id = v_project_id;

    IF v_total > 0 THEN
        v_done_rate := (v_done::NUMERIC / v_total) * 100;
    ELSE
        v_done_rate := 0;
    END IF;

    CASE
        WHEN v_done_rate = 100 THEN
            RAISE NOTICE '全タスク完了! (100%%)';
        WHEN v_done_rate >= 75 THEN
            RAISE NOTICE 'ほぼ完了 (%.1f%%)', v_done_rate;
        WHEN v_done_rate >= 50 THEN
            RAISE NOTICE '半分以上完了 (%.1f%%)', v_done_rate;
        WHEN v_done_rate >= 25 THEN
            RAISE NOTICE '進行中 (%.1f%%)', v_done_rate;
        ELSE
            RAISE NOTICE 'まだ序盤 (%.1f%%)', v_done_rate;
    END CASE;
END;
$$;
