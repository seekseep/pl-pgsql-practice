# 配列 (ARRAY) と JSON

## 0. 配列の宣言と基本操作

**ファイル:** `sql/3-array-json/0-array-basics.sql`

PL/pgSQL での配列の宣言方法と、要素のアクセス・長さ取得などの基本操作を示します。

```sql
-- ============================================================
-- 配列の宣言と基本操作
-- ============================================================

DO $$
DECLARE
    v_names  TEXT[] := ARRAY['営業部', '開発部', '人事部'];
    v_scores INT[]  := ARRAY[85, 92, 78, 95];
BEGIN
    RAISE NOTICE '配列: %', v_names;
    RAISE NOTICE '要素数: %', array_length(v_names, 1);
    RAISE NOTICE '1番目: %', v_names[1];
    RAISE NOTICE '3番目: %', v_names[3];
END;
$$;
```

実行方法:

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/4-advanced-control/sql/3-array-json/0-array-basics.sql
```

## 1. FOREACH で配列をループ

**ファイル:** `sql/3-array-json/1-foreach.sql`

`FOREACH ... IN ARRAY` 構文を使って、配列の各要素を順に処理します。各ステータスごとのタスク件数を集計する例です。

```sql
-- ============================================================
-- FOREACH で配列をループ
-- ============================================================

DO $$
DECLARE
    v_statuses TEXT[] := ARRAY['todo', 'in_progress', 'in_review', 'done'];
    v_status   TEXT;
    v_count    INT;
BEGIN
    FOREACH v_status IN ARRAY v_statuses LOOP
        SELECT COUNT(*) INTO v_count FROM tasks WHERE status = v_status;
        RAISE NOTICE '% : % 件', v_status, v_count;
    END LOOP;
END;
$$;
```

実行方法:

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/4-advanced-control/sql/3-array-json/1-foreach.sql
```

## 2. array_agg で配列を作成

**ファイル:** `sql/3-array-json/2-array-agg.sql`

`array_agg` 集約関数を使って、クエリ結果から配列を生成します。プロジェクトメンバーの名前一覧を配列として取得する例です。

```sql
-- ============================================================
-- array_agg で配列を作成
-- ============================================================

DO $$
DECLARE
    v_members TEXT[];
BEGIN
    SELECT array_agg(e.last_name || ' ' || e.first_name ORDER BY e.id)
    INTO v_members
    FROM project_members pm
    INNER JOIN employees e ON pm.employee_id = e.id
    WHERE pm.project_id = 1;

    RAISE NOTICE 'プロジェクト1のメンバー: %', v_members;
    RAISE NOTICE '人数: %', array_length(v_members, 1);
END;
$$;
```

実行方法:

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/4-advanced-control/sql/3-array-json/2-array-agg.sql
```

## 3. ANY / ALL で配列を条件に使う

**ファイル:** `sql/3-array-json/3-any-all.sql`

`ANY()` を使って配列内のいずれかの値に一致する条件を指定します。動的に対象部署を集めてから従業員を検索する例です。

```sql
-- ============================================================
-- ANY / ALL で配列を条件に使う
-- ============================================================

DO $$
DECLARE
    v_target_depts INT[];
    v_rec RECORD;
BEGIN
    SELECT array_agg(id) INTO v_target_depts
    FROM departments
    WHERE name IN ('開発部', '営業部');

    RAISE NOTICE '対象部署ID: %', v_target_depts;

    FOR v_rec IN
        SELECT id, last_name, first_name, department_id
        FROM employees
        WHERE department_id = ANY(v_target_depts)
        ORDER BY id
        LIMIT 5
    LOOP
        RAISE NOTICE 'ID=%, % % (部署ID=%)', v_rec.id, v_rec.last_name, v_rec.first_name, v_rec.department_id;
    END LOOP;
END;
$$;
```

実行方法:

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/4-advanced-control/sql/3-array-json/3-any-all.sql
```

## 4. 配列の操作 (追加、結合、削除)

**ファイル:** `sql/3-array-json/4-array-operations.sql`

`array_append`、`array_prepend`、`||` 演算子、`array_remove` を使った配列の追加・結合・削除操作を示します。

```sql
-- ============================================================
-- 配列の操作 (追加、結合、削除)
-- ============================================================

DO $$
DECLARE
    v_arr TEXT[] := ARRAY['A', 'B', 'C'];
BEGIN
    v_arr := array_append(v_arr, 'D');
    RAISE NOTICE '末尾追加: %', v_arr;

    v_arr := array_prepend('Z', v_arr);
    RAISE NOTICE '先頭追加: %', v_arr;

    v_arr := v_arr || ARRAY['X', 'Y'];
    RAISE NOTICE '結合: %', v_arr;

    v_arr := array_remove(v_arr, 'Z');
    RAISE NOTICE '削除: %', v_arr;
END;
$$;
```

実行方法:

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/4-advanced-control/sql/3-array-json/4-array-operations.sql
```

## 5. JSON の作成と参照

**ファイル:** `sql/3-array-json/5-json-basics.sql`

`jsonb_build_object` と `jsonb_build_array` で JSONB データを作成し、`->>` 演算子や `->` 演算子で値を参照します。

```sql
-- ============================================================
-- JSON の作成と参照
-- ============================================================

DO $$
DECLARE
    v_data JSONB;
BEGIN
    v_data := jsonb_build_object(
        'department', '開発部',
        'member_count', 15,
        'is_active', TRUE,
        'tags', jsonb_build_array('engineering', 'backend')
    );

    RAISE NOTICE 'JSON: %', v_data;
    RAISE NOTICE '部署: %', v_data->>'department';
    RAISE NOTICE '人数: %', (v_data->>'member_count')::INT;
    RAISE NOTICE 'タグ1: %', v_data->'tags'->>0;
END;
$$;
```

実行方法:

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/4-advanced-control/sql/3-array-json/5-json-basics.sql
```

## 6. row_to_json でレコードを JSON に変換

**ファイル:** `sql/3-array-json/6-row-to-json.sql`

`to_jsonb` を使ってクエリ結果のレコードを JSONB 形式に変換します。レコードの各フィールドに `->>` でアクセスできます。

```sql
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
```

実行方法:

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/4-advanced-control/sql/3-array-json/6-row-to-json.sql
```

## 7. jsonb_agg で集約結果を JSON 配列にする

**ファイル:** `sql/3-array-json/7-jsonb-agg.sql`

`jsonb_agg` と `jsonb_build_object` を組み合わせて、集約結果を JSON 配列として取得します。部署一覧と従業員数をまとめて JSON 化する例です。

```sql
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
```

実行方法:

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/4-advanced-control/sql/3-array-json/7-jsonb-agg.sql
```

## 8. jsonb_each でキーと値をループ

**ファイル:** `sql/3-array-json/8-jsonb-each.sql`

`jsonb_each` を使って JSONB オブジェクトのキーと値を順に取り出してループ処理します。設定値の一覧表示などに便利です。

```sql
-- ============================================================
-- jsonb_each でキーと値をループ
-- ============================================================

DO $$
DECLARE
    v_config JSONB := '{
        "max_retries": 3,
        "timeout_sec": 30,
        "batch_size": 100,
        "log_level": "info"
    }';
    v_key   TEXT;
    v_value JSONB;
BEGIN
    FOR v_key, v_value IN SELECT * FROM jsonb_each(v_config)
    LOOP
        RAISE NOTICE '設定: % = %', v_key, v_value;
    END LOOP;
END;
$$;
```

実行方法:

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/4-advanced-control/sql/3-array-json/8-jsonb-each.sql
```

## 9. JSONB パス演算子 (@>, ?, #>>)

**ファイル:** `sql/3-array-json/9-jsonb-operators.sql`

JSONB の高度な演算子を使った操作です。`?` でキーの存在確認、`@>` で包含チェック、`#>>` でネストされたパスの値を取得します。

```sql
-- ============================================================
-- JSONB パス演算子 (@>, ?, #>>)
-- ============================================================

DO $$
DECLARE
    v_data JSONB := '{
        "project": "API開発",
        "members": [
            {"name": "田中", "role": "manager"},
            {"name": "鈴木", "role": "member"},
            {"name": "佐藤", "role": "reviewer"}
        ]
    }';
BEGIN
    IF v_data ? 'project' THEN
        RAISE NOTICE 'project キーあり: %', v_data->>'project';
    END IF;

    IF v_data @> '{"project": "API開発"}' THEN
        RAISE NOTICE '包含チェック OK';
    END IF;

    RAISE NOTICE '最初のメンバー: %', v_data#>>'{members,0,name}';
    RAISE NOTICE '2番目の役割: %', v_data#>>'{members,1,role}';
END;
$$;
```

実行方法:

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/4-advanced-control/sql/3-array-json/9-jsonb-operators.sql
```

---

← [前へ: 動的 SQL (EXECUTE)](2-dynamic-sql.md) | [ADVANCED_CONTROL](README.md) | [次へ: CTE (WITH 句) とウィンドウ関数](4-cte-window.md) →
