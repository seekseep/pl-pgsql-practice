-- ============================================================
-- 配列の宣言と基本操作
-- ============================================================

DO $$
DECLARE
    v_names  TEXT[] := ARRAY['営業部', '開発部', '人事部'];
    v_scores INT[]  := ARRAY[85, 92, 78, 95];
BEGIN
    RAISE NOTICE '配列: %', v_names;
    RAISE NOTICE '要素数: %', array_length(v_names, 1);
    RAISE NOTICE '1番目: %', v_names[1];
    RAISE NOTICE '3番目: %', v_names[3];
END;
$$;
