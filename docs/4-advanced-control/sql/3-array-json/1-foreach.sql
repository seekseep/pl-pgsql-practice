-- ============================================================
-- FOREACH で配列をループ
-- ============================================================

DO $$
DECLARE
    v_statuses TEXT[] := ARRAY['todo', 'in_progress', 'in_review', 'done'];
    v_status   TEXT;
    v_count    INT;
BEGIN
    FOREACH v_status IN ARRAY v_statuses LOOP
        SELECT COUNT(*) INTO v_count FROM tasks WHERE status = v_status;
        RAISE NOTICE '% : % 件', v_status, v_count;
    END LOOP;
END;
$$;
