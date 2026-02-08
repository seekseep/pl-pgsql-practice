# 関数 (FUNCTION) とトリガー (TRIGGER)

## 1. 基本的な関数 (引数なし)

**ファイル:** `sql/6-function-trigger/1-basic-function.sql`

引数なしの基本的な PL/pgSQL 関数を定義します。`CREATE OR REPLACE FUNCTION` でアクティブな従業員数を返す関数を作成し、`DO` ブロックで呼び出す例です。

```sql
-- ============================================================
-- 基本的な関数 (引数なし)
-- ============================================================

CREATE OR REPLACE FUNCTION count_active_employees()
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM employees
    WHERE is_active = TRUE;

    RETURN v_count;
END;
$$;

-- 実行テスト
DO $$
BEGIN
    RAISE NOTICE 'アクティブ従業員数: %', count_active_employees();
END;
$$;
```

## 2. 引数付き関数

**ファイル:** `sql/6-function-trigger/2-args-function.sql`

引数を受け取る関数の定義方法を示します。部署 ID を引数にとり、その部署のアクティブ従業員数を返します。

```sql
-- ============================================================
-- 引数付き関数
-- ============================================================

CREATE OR REPLACE FUNCTION get_department_employee_count(
    p_dept_id INT
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM employees
    WHERE department_id = p_dept_id
      AND is_active = TRUE;

    RETURN v_count;
END;
$$;

-- 実行テスト
DO $$
DECLARE
    v_rec RECORD;
BEGIN
    FOR v_rec IN SELECT id, name FROM departments ORDER BY id
    LOOP
        RAISE NOTICE '%: % 人',
            v_rec.name, get_department_employee_count(v_rec.id);
    END LOOP;
END;
$$;
```

## 3. RETURNS TABLE 関数

**ファイル:** `sql/6-function-trigger/3-returns-table.sql`

`RETURNS TABLE` を使って複数行・複数列を返す関数を定義します。`RETURN QUERY` で結果セットを返し、通常のテーブルのように `SELECT * FROM` で呼び出せます。

```sql
-- ============================================================
-- RETURNS TABLE 関数
-- ============================================================

CREATE OR REPLACE FUNCTION get_department_members(p_dept_id INT)
RETURNS TABLE (
    employee_id   INT,
    full_name     TEXT,
    email         VARCHAR,
    hire_date     DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.id,
        e.last_name || ' ' || e.first_name,
        e.email,
        e.hire_date
    FROM employees e
    WHERE e.department_id = p_dept_id
      AND e.is_active = TRUE
    ORDER BY e.hire_date;
END;
$$;

-- 実行テスト
DO $$
DECLARE
    v_rec RECORD;
BEGIN
    RAISE NOTICE '=== 部署ID=1 のメンバー ===';
    FOR v_rec IN SELECT * FROM get_department_members(1)
    LOOP
        RAISE NOTICE '  [%] % (%) 入社: %',
            v_rec.employee_id, v_rec.full_name,
            v_rec.email, v_rec.hire_date;
    END LOOP;
END;
$$;
```

## 4. SETOF RECORD を返す関数

**ファイル:** `sql/6-function-trigger/4-setof-record.sql`

`RETURNS TABLE` を使ってプロジェクトのサマリ情報（名前、ステータス、メンバー数、タスク数）を集約して返す関数です。

```sql
-- ============================================================
-- SETOF RECORD を返す関数
-- ============================================================

CREATE OR REPLACE FUNCTION get_project_summary()
RETURNS TABLE (
    project_name VARCHAR,
    status       VARCHAR,
    member_count BIGINT,
    task_count   BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.name,
        p.status,
        COUNT(DISTINCT pm.employee_id),
        COUNT(DISTINCT t.id)
    FROM projects p
    LEFT JOIN project_members pm ON p.id = pm.project_id
    LEFT JOIN tasks t ON p.id = t.project_id
    GROUP BY p.id, p.name, p.status
    ORDER BY p.id;
END;
$$;

-- 実行テスト
DO $$
DECLARE
    v_rec RECORD;
BEGIN
    FOR v_rec IN SELECT * FROM get_project_summary()
    LOOP
        RAISE NOTICE '% [%] メンバー: % タスク: %',
            v_rec.project_name, v_rec.status,
            v_rec.member_count, v_rec.task_count;
    END LOOP;
END;
$$;
```

## 5. updated_at 自動更新トリガー

**ファイル:** `sql/6-function-trigger/5-updated-at-trigger.sql`

`BEFORE UPDATE` トリガーを使って `updated_at` カラムを自動的に現在時刻で更新します。トリガー関数で `NEW.updated_at` を書き換えるパターンです。

```sql
-- ============================================================
-- updated_at 自動更新トリガー
-- ============================================================

CREATE OR REPLACE FUNCTION trigger_set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- employees テーブルにトリガーを設定
DROP TRIGGER IF EXISTS trg_employees_updated_at ON employees;
CREATE TRIGGER trg_employees_updated_at
    BEFORE UPDATE ON employees
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_updated_at();

-- 動作確認
DO $$
DECLARE
    v_before TIMESTAMP;
    v_after  TIMESTAMP;
BEGIN
    SELECT updated_at INTO v_before FROM employees WHERE id = 1;
    RAISE NOTICE '更新前: %', v_before;

    PERFORM pg_sleep(0.1);

    UPDATE employees SET first_name = first_name WHERE id = 1;

    SELECT updated_at INTO v_after FROM employees WHERE id = 1;
    RAISE NOTICE '更新後: %', v_after;
    RAISE NOTICE 'updated_at が自動更新されました: %', v_after > v_before;
END;
$$;
```

## 6. 監査ログトリガー

**ファイル:** `sql/6-function-trigger/6-audit-trigger.sql`

`AFTER INSERT OR UPDATE OR DELETE` トリガーで監査ログを自動記録します。`TG_OP` で操作種別を判定し、`to_jsonb(OLD)` / `to_jsonb(NEW)` で変更前後のデータを JSONB として保存します。

```sql
-- ============================================================
-- 監査ログトリガー
-- ============================================================

-- 監査ログテーブル (存在しない場合のみ作成)
CREATE TABLE IF NOT EXISTS audit_logs (
    id          SERIAL PRIMARY KEY,
    table_name  TEXT        NOT NULL,
    operation   TEXT        NOT NULL,
    record_id   INT,
    old_data    JSONB,
    new_data    JSONB,
    changed_at  TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION trigger_audit_log()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit_logs (table_name, operation, record_id, new_data)
        VALUES (TG_TABLE_NAME, TG_OP, NEW.id, to_jsonb(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_logs (table_name, operation, record_id, old_data, new_data)
        VALUES (TG_TABLE_NAME, TG_OP, NEW.id, to_jsonb(OLD), to_jsonb(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit_logs (table_name, operation, record_id, old_data)
        VALUES (TG_TABLE_NAME, TG_OP, OLD.id, to_jsonb(OLD));
        RETURN OLD;
    END IF;
END;
$$;

-- departments テーブルに監査トリガーを設定
DROP TRIGGER IF EXISTS trg_departments_audit ON departments;
CREATE TRIGGER trg_departments_audit
    AFTER INSERT OR UPDATE OR DELETE ON departments
    FOR EACH ROW
    EXECUTE FUNCTION trigger_audit_log();

-- 動作確認
DO $$
DECLARE
    v_rec RECORD;
BEGIN
    -- テスト用の更新
    UPDATE departments SET name = name WHERE id = 1;

    -- 監査ログを確認
    FOR v_rec IN
        SELECT operation, record_id, changed_at
        FROM audit_logs
        WHERE table_name = 'departments'
        ORDER BY id DESC
        LIMIT 3
    LOOP
        RAISE NOTICE '操作: % | レコードID: % | 日時: %',
            v_rec.operation, v_rec.record_id, v_rec.changed_at;
    END LOOP;
END;
$$;

-- クリーンアップ (トリガーを削除)
DROP TRIGGER IF EXISTS trg_departments_audit ON departments;
```

## 7. 関数の削除 (DROP FUNCTION)

**ファイル:** `sql/6-function-trigger/7-drop-function.sql`

このセクションで作成した関数やトリガーをまとめて削除します。`DROP FUNCTION IF EXISTS` で安全に削除し、依存するトリガーも先に削除します。

```sql
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
```

---

← [前へ: CTE (WITH 句) とウィンドウ関数](5-cte-window.md) | [ADVANCED_CONTROL](README.md)
