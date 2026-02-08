-- ============================================================
-- array_agg で配列を作成
-- ============================================================

DO $$
DECLARE
    v_members TEXT[];
BEGIN
    SELECT array_agg(e.last_name || ' ' || e.first_name ORDER BY e.id)
    INTO v_members
    FROM project_members pm
    INNER JOIN employees e ON pm.employee_id = e.id
    WHERE pm.project_id = 1;

    RAISE NOTICE 'プロジェクト1のメンバー: %', v_members;
    RAISE NOTICE '人数: %', array_length(v_members, 1);
END;
$$;
