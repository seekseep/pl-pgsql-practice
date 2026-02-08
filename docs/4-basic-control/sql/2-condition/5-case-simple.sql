-- ============================================================
-- CASE 文 (単純 CASE)
-- ============================================================
-- 1 つの値を複数の候補と比較して分岐する

DO $$
DECLARE
    v_project projects%ROWTYPE;
    v_label   VARCHAR(20);
BEGIN
    SELECT * INTO v_project FROM projects WHERE id = 1;

    CASE v_project.status
        WHEN 'planning'  THEN v_label := '計画中';
        WHEN 'active'    THEN v_label := '進行中';
        WHEN 'completed' THEN v_label := '完了';
        WHEN 'archived'  THEN v_label := 'アーカイブ済';
        ELSE v_label := '不明';
    END CASE;

    RAISE NOTICE 'プロジェクト「%」のステータス: %', v_project.name, v_label;
END;
$$;
