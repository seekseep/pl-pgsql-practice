# 動的 SQL (EXECUTE)

## 1. EXECUTE の基本

**ファイル:** `sql/3-dynamic-sql/1-basic-execute.sql`

`EXECUTE` を使うと、SQL 文を文字列として組み立てて動的に実行できます。結果は `INTO` で変数に格納します。

```sql
-- ============================================================
-- EXECUTE の基本
-- ============================================================
-- SQL 文を文字列として組み立てて実行する

DO $$
DECLARE
    v_count INT;
BEGIN
    EXECUTE 'SELECT COUNT(*) FROM employees' INTO v_count;
    RAISE NOTICE '従業員数: %', v_count;
END;
$$;
```

## 2. USING によるパラメータバインド

**ファイル:** `sql/3-dynamic-sql/2-using-params.sql`

SQL インジェクション対策のため、値は `USING` 句で安全にバインドします。`$1`, `$2` などのプレースホルダを使います。

```sql
-- ============================================================
-- USING によるパラメータバインド
-- ============================================================
-- SQL インジェクション対策のため、値は USING で渡す

DO $$
DECLARE
    v_rec RECORD;
BEGIN
    FOR v_rec IN
        EXECUTE 'SELECT id, last_name, first_name FROM employees WHERE department_id = $1 AND is_active = $2 ORDER BY id LIMIT 5'
        USING 2, TRUE
    LOOP
        RAISE NOTICE 'ID=%, % %', v_rec.id, v_rec.last_name, v_rec.first_name;
    END LOOP;
END;
$$;
```

## 3. テーブル名を動的に指定

**ファイル:** `sql/3-dynamic-sql/3-dynamic-table.sql`

テーブル名は `USING` で渡せないため、`format()` 関数の `%I` 指定子を使って安全に識別子を埋め込みます。

```sql
-- ============================================================
-- テーブル名を動的に指定
-- ============================================================
-- テーブル名は USING で渡せないため format() + %I を使う

DO $$
DECLARE
    v_table_name TEXT;
    v_count      INT;
    v_tables     TEXT[] := ARRAY['departments', 'employees', 'projects', 'tasks'];
BEGIN
    FOREACH v_table_name IN ARRAY v_tables LOOP
        EXECUTE format('SELECT COUNT(*) FROM %I', v_table_name) INTO v_count;
        RAISE NOTICE '% : % 件', v_table_name, v_count;
    END LOOP;
END;
$$;
```

## 4. format() の書式指定子

**ファイル:** `sql/3-dynamic-sql/4-format-specifiers.sql`

`format()` 関数の書式指定子の使い分けを示します。`%I` は識別子（自動クォート）、`%L` はリテラル（自動エスケープ）、`%s` はそのまま埋め込みです。

```sql
-- ============================================================
-- format() の書式指定子
-- ============================================================
-- %I = 識別子 (テーブル名、カラム名) → 自動クォート
-- %L = リテラル (値) → 自動エスケープ
-- %s = そのまま (信頼できる文字列のみ)

DO $$
DECLARE
    v_rec RECORD;
    v_sql TEXT;
BEGIN
    v_sql := format(
        'SELECT id, %I, %I FROM %I WHERE %I = %L ORDER BY id LIMIT 3',
        'last_name', 'first_name',
        'employees',
        'is_active',
        'true'
    );

    RAISE NOTICE 'SQL: %', v_sql;

    FOR v_rec IN EXECUTE v_sql LOOP
        RAISE NOTICE 'ID=%, % %', v_rec.id, v_rec.last_name, v_rec.first_name;
    END LOOP;
END;
$$;
```

## 5. 動的 SQL で INSERT

**ファイル:** `sql/3-dynamic-sql/5-dynamic-insert.sql`

`format()` で `INSERT` 文を動的に組み立てて実行します。`RETURNING` と `INTO` を組み合わせて、挿入結果を取得することもできます。

```sql
-- ============================================================
-- 動的 SQL で INSERT
-- ============================================================
-- format() で INSERT 文を組み立てて実行する

DO $$
DECLARE
    v_new_id INT;
BEGIN
    EXECUTE format(
        'INSERT INTO %I (name) VALUES (%L) RETURNING id',
        'departments', '動的SQL部'
    ) INTO v_new_id;

    RAISE NOTICE '動的 INSERT 成功: ID=%', v_new_id;

    EXECUTE 'DELETE FROM departments WHERE id = $1' USING v_new_id;
END;
$$;
```

## 6. 動的 SQL で条件を組み立てる

**ファイル:** `sql/3-dynamic-sql/6-dynamic-conditions.sql`

検索条件を動的に構築するパターンです。パラメータが `NULL` の場合は条件を追加しないことで、柔軟な検索を実現します。

```sql
-- ============================================================
-- 動的 SQL で条件を組み立てる
-- ============================================================
-- 検索条件を動的に構築するパターン

DO $$
DECLARE
    v_sql    TEXT;
    v_rec    RECORD;
    -- 検索パラメータ (NULL = 条件なし)
    p_status     VARCHAR := 'active';
    p_start_date DATE    := '2025-01-01';
    p_end_date   DATE    := NULL;
BEGIN
    v_sql := 'SELECT id, name, status, start_date FROM projects WHERE 1=1';

    IF p_status IS NOT NULL THEN
        v_sql := v_sql || format(' AND status = %L', p_status);
    END IF;

    IF p_start_date IS NOT NULL THEN
        v_sql := v_sql || format(' AND start_date >= %L', p_start_date);
    END IF;

    IF p_end_date IS NOT NULL THEN
        v_sql := v_sql || format(' AND end_date <= %L', p_end_date);
    END IF;

    v_sql := v_sql || ' ORDER BY id';

    RAISE NOTICE '実行SQL: %', v_sql;

    FOR v_rec IN EXECUTE v_sql LOOP
        RAISE NOTICE '[%] % (開始: %)', v_rec.status, v_rec.name, v_rec.start_date;
    END LOOP;
END;
$$;
```

## 7. EXECUTE ... INTO STRICT

**ファイル:** `sql/3-dynamic-sql/7-execute-strict.sql`

`INTO STRICT` を使うことで、動的 SQL の結果が正確に 1 行であることを保証します。0 行や複数行の場合は例外が発生します。

```sql
-- ============================================================
-- EXECUTE ... INTO STRICT
-- ============================================================
-- 結果が正確に 1 行であることを保証する

DO $$
DECLARE
    v_name VARCHAR(100);
BEGIN
    EXECUTE 'SELECT name FROM departments WHERE id = $1'
    INTO STRICT v_name
    USING 1;

    RAISE NOTICE '部署名: %', v_name;
EXCEPTION
    WHEN no_data_found THEN
        RAISE NOTICE '該当なし';
    WHEN too_many_rows THEN
        RAISE NOTICE '複数件該当';
END;
$$;
```

---

← [前へ: RETURNING INTO](2-returning-into.md) | [ADVANCED_CONTROL](README.md) | [次へ: 配列 (ARRAY) と JSON](4-array-json.md) →
