-- ============================================================
-- %TYPE による型の参照
-- ============================================================
-- テーブルのカラムと同じ型の変数を宣言する

DO $$
DECLARE
    v_last_name  employees.last_name%TYPE;
    v_first_name employees.first_name%TYPE;
    v_email      employees.email%TYPE;
BEGIN
    SELECT last_name, first_name, email
    INTO v_last_name, v_first_name, v_email
    FROM employees
    WHERE id = 1;

    RAISE NOTICE '従業員: % % (%)', v_last_name, v_first_name, v_email;
END;
$$;
