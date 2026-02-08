-- ============================================================
-- 複数の例外をキャッチ
-- ============================================================
-- WHEN を複数書いて、例外の種類ごとに処理を分ける

DO $$
DECLARE
    v_emp employees%ROWTYPE;
BEGIN
    -- INTO STRICT: 結果が 0 行 or 2 行以上で例外
    SELECT * INTO STRICT v_emp FROM employees WHERE id = 99999;
    RAISE NOTICE '従業員: % %', v_emp.last_name, v_emp.first_name;
EXCEPTION
    WHEN no_data_found THEN
        RAISE NOTICE 'エラー: 該当する従業員が見つかりません';
    WHEN too_many_rows THEN
        RAISE NOTICE 'エラー: 複数のレコードが該当しました';
END;
$$;
