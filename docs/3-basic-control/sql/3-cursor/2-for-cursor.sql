-- ============================================================
-- FOR ループによるカーソルの簡略化
-- ============================================================
-- FOR ループを使うと OPEN / FETCH / CLOSE を自動で行ってくれる

DO $$
DECLARE
    cur_depts CURSOR FOR
        SELECT d.id, d.name, COUNT(e.id) AS emp_count
        FROM departments d
        LEFT JOIN employees e ON d.id = e.department_id
        GROUP BY d.id, d.name
        ORDER BY d.id;
BEGIN
    FOR v_rec IN cur_depts LOOP
        RAISE NOTICE '部署[%]: % (% 人)', v_rec.id, v_rec.name, v_rec.emp_count;
    END LOOP;
    -- CLOSE は自動で呼ばれる
END;
$$;
