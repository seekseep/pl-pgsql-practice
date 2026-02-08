-- ============================================================
-- 配列の操作 (追加、結合、削除)
-- ============================================================

DO $$
DECLARE
    v_arr TEXT[] := ARRAY['A', 'B', 'C'];
BEGIN
    v_arr := array_append(v_arr, 'D');
    RAISE NOTICE '末尾追加: %', v_arr;

    v_arr := array_prepend('Z', v_arr);
    RAISE NOTICE '先頭追加: %', v_arr;

    v_arr := v_arr || ARRAY['X', 'Y'];
    RAISE NOTICE '結合: %', v_arr;

    v_arr := array_remove(v_arr, 'Z');
    RAISE NOTICE '削除: %', v_arr;
END;
$$;
