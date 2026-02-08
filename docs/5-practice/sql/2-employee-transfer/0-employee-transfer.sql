-- ============================================================
-- 課題 2: 従業員異動処理
-- ============================================================
-- 従業員を別の部署に異動させる関数
-- 学習ポイント: バリデーション, RAISE EXCEPTION, EXCEPTION ブロック

CREATE OR REPLACE FUNCTION transfer_employee(
    p_employee_id  INT,
    p_new_dept_id  INT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_emp       RECORD;
    v_old_dept  VARCHAR;
    v_new_dept  VARCHAR;
BEGIN
    -- 従業員の存在チェック
    SELECT e.id, e.last_name, e.first_name,
           e.department_id, e.is_active, d.name AS dept_name
    INTO v_emp
    FROM employees e
    INNER JOIN departments d ON e.department_id = d.id
    WHERE e.id = p_employee_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION '従業員ID=% は存在しません', p_employee_id;
    END IF;

    -- 在籍チェック
    IF NOT v_emp.is_active THEN
        RAISE EXCEPTION '従業員 % % は退職済みです',
            v_emp.last_name, v_emp.first_name;
    END IF;

    v_old_dept := v_emp.dept_name;

    -- 異動先部署の存在チェック
    SELECT name INTO v_new_dept
    FROM departments
    WHERE id = p_new_dept_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION '異動先の部署ID=% は存在しません', p_new_dept_id;
    END IF;

    -- 同じ部署チェック
    IF v_emp.department_id = p_new_dept_id THEN
        RAISE EXCEPTION '% % は既に % に所属しています',
            v_emp.last_name, v_emp.first_name, v_new_dept;
    END IF;

    -- 異動実行
    UPDATE employees
    SET department_id = p_new_dept_id,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = p_employee_id;

    RAISE NOTICE '========================================';
    RAISE NOTICE '異動完了';
    RAISE NOTICE '従業員: % %', v_emp.last_name, v_emp.first_name;
    RAISE NOTICE '異動元: %', v_old_dept;
    RAISE NOTICE '異動先: %', v_new_dept;
    RAISE NOTICE '========================================';

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'エラー: %', SQLERRM;
END;
$$;

-- 実行テスト: 正常な異動
SELECT transfer_employee(1, 3);

-- 元に戻す
DO $$
DECLARE
    v_dept_id INT;
BEGIN
    SELECT department_id INTO v_dept_id FROM employees WHERE id = 1;
    IF v_dept_id = 3 THEN
        UPDATE employees SET department_id = 1 WHERE id = 1;
        RAISE NOTICE '従業員ID=1 を元の部署に戻しました';
    END IF;
END;
$$;

-- 実行テスト: 存在しない従業員
SELECT transfer_employee(9999, 1);

-- 実行テスト: 同じ部署
SELECT transfer_employee(1, 1);

-- クリーンアップ
DROP FUNCTION IF EXISTS transfer_employee(INT, INT);
