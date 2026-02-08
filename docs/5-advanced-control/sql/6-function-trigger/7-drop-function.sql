-- ============================================================
-- 関数の削除 (DROP FUNCTION)
-- ============================================================

-- このファイルのセクションで作成した関数を削除します

DO $$
BEGIN
    RAISE NOTICE '=== 関数を削除します ===';
END;
$$;

-- 関数の一覧を確認
DO $$
DECLARE
    v_rec RECORD;
BEGIN
    FOR v_rec IN
        SELECT routine_name, routine_type
        FROM information_schema.routines
        WHERE routine_schema = 'public'
          AND routine_type = 'FUNCTION'
          AND routine_name IN (
              'count_active_employees',
              'get_department_employee_count',
              'get_department_members',
              'get_project_summary',
              'trigger_set_updated_at',
              'trigger_audit_log'
          )
        ORDER BY routine_name
    LOOP
        RAISE NOTICE '  関数: %', v_rec.routine_name;
    END LOOP;
END;
$$;

-- 関数を削除
DROP FUNCTION IF EXISTS count_active_employees();
DROP FUNCTION IF EXISTS get_department_employee_count(INT);
DROP FUNCTION IF EXISTS get_department_members(INT);
DROP FUNCTION IF EXISTS get_project_summary();

-- トリガー関数を削除 (依存トリガーも先に削除)
DROP TRIGGER IF EXISTS trg_employees_updated_at ON employees;
DROP FUNCTION IF EXISTS trigger_set_updated_at();
DROP FUNCTION IF EXISTS trigger_audit_log();

-- 監査ログテーブルを削除
DROP TABLE IF EXISTS audit_logs;

DO $$
BEGIN
    RAISE NOTICE '=== 削除完了 ===';
END;
$$;
