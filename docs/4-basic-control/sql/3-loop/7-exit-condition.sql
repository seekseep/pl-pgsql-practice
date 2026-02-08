-- ============================================================
-- EXIT (条件付き脱出)
-- ============================================================
-- 特定の条件でループを途中終了する

DO $$
DECLARE
    v_rec RECORD;
BEGIN
    FOR v_rec IN
        SELECT t.id, t.title, t.priority, p.name AS project_name
        FROM tasks t
        INNER JOIN projects p ON t.project_id = p.id
        ORDER BY t.id
    LOOP
        IF v_rec.priority = 'urgent' THEN
            RAISE NOTICE '緊急タスク発見! [%] % (プロジェクト: %)',
                v_rec.id, v_rec.title, v_rec.project_name;
            EXIT;
        END IF;
    END LOOP;
END;
$$;
