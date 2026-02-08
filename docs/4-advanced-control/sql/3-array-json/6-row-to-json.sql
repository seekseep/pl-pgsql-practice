-- ============================================================
-- row_to_json でレコードを JSON に変換
-- ============================================================

DO $$
DECLARE
    v_rec  RECORD;
    v_json JSONB;
BEGIN
    SELECT e.id, e.last_name, e.first_name, e.email, d.name AS department
    INTO v_rec
    FROM employees e
    INNER JOIN departments d ON e.department_id = d.id
    WHERE e.id = 1;

    v_json := to_jsonb(v_rec);
    RAISE NOTICE '従業員JSON: %', v_json;
    RAISE NOTICE '名前: % %', v_json->>'last_name', v_json->>'first_name';
END;
$$;
