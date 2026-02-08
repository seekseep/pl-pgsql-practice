-- ============================================================
-- ラベル付きループ
-- ============================================================
-- <<label>> でループに名前を付け、外側のループを CONTINUE / EXIT できる

DO $$
DECLARE
    v_dept RECORD;
    v_emp  RECORD;
    v_cnt  INT;
BEGIN
    <<dept_loop>>
    FOR v_dept IN SELECT id, name FROM departments ORDER BY id LOOP
        v_cnt := 0;

        <<emp_loop>>
        FOR v_emp IN
            SELECT id, last_name, first_name
            FROM employees
            WHERE department_id = v_dept.id
            ORDER BY id
        LOOP
            v_cnt := v_cnt + 1;

            IF v_cnt > 3 THEN
                RAISE NOTICE '  ... (他にもメンバーがいます)';
                CONTINUE dept_loop;  -- 外側のループの次の反復へ
            END IF;

            RAISE NOTICE '[%] % %', v_dept.name, v_emp.last_name, v_emp.first_name;
        END LOOP emp_loop;
    END LOOP dept_loop;
END;
$$;
