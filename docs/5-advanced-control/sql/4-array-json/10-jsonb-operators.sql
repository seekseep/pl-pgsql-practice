-- ============================================================
-- JSONB パス演算子 (@>, ?, #>>)
-- ============================================================

DO $$
DECLARE
    v_data JSONB := '{
        "project": "API開発",
        "members": [
            {"name": "田中", "role": "manager"},
            {"name": "鈴木", "role": "member"},
            {"name": "佐藤", "role": "reviewer"}
        ]
    }';
BEGIN
    IF v_data ? 'project' THEN
        RAISE NOTICE 'project キーあり: %', v_data->>'project';
    END IF;

    IF v_data @> '{"project": "API開発"}' THEN
        RAISE NOTICE '包含チェック OK';
    END IF;

    RAISE NOTICE '最初のメンバー: %', v_data#>>'{members,0,name}';
    RAISE NOTICE '2番目の役割: %', v_data#>>'{members,1,role}';
END;
$$;
