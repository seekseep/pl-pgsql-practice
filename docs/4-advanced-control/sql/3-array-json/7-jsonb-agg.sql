-- ============================================================
-- jsonb_agg で集約結果を JSON 配列にする
-- ============================================================

DO $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_agg(jsonb_build_object(
        'id', d.id,
        'name', d.name,
        'employee_count', sub.cnt
    ) ORDER BY d.id)
    INTO v_result
    FROM departments d
    LEFT JOIN (
        SELECT department_id, COUNT(*) AS cnt
        FROM employees
        GROUP BY department_id
    ) sub ON d.id = sub.department_id;

    RAISE NOTICE '部署一覧JSON: %', v_result;
END;
$$;
