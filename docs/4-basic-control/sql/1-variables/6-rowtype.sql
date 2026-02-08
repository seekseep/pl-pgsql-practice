-- ============================================================
-- %ROWTYPE による行型の変数
-- ============================================================
-- テーブルの 1 行をまるごと変数に格納する

DO $$
DECLARE
    v_employee employees%ROWTYPE;
BEGIN
    SELECT * INTO v_employee
    FROM employees
    WHERE id = 1;

    RAISE NOTICE 'ID: %, 名前: % %, 入社日: %',
        v_employee.id,
        v_employee.last_name,
        v_employee.first_name,
        v_employee.hire_date;
END;
$$;
