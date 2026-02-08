-- ============================================================
-- JSON の作成と参照
-- ============================================================

DO $$
DECLARE
    v_data JSONB;
BEGIN
    v_data := jsonb_build_object(
        'department', '開発部',
        'member_count', 15,
        'is_active', TRUE,
        'tags', jsonb_build_array('engineering', 'backend')
    );

    RAISE NOTICE 'JSON: %', v_data;
    RAISE NOTICE '部署: %', v_data->>'department';
    RAISE NOTICE '人数: %', (v_data->>'member_count')::INT;
    RAISE NOTICE 'タグ1: %', v_data->'tags'->>0;
END;
$$;
