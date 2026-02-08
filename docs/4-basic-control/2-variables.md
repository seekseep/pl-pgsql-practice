# 変数

## 全体の流れ

| # | テーマ | 概要 |
|---|---|---|
| 1 | [変数の宣言と代入](#0-変数の宣言と代入) | `DECLARE` + `:=` で基本型の変数を扱う |
| 2 | [デフォルト値付きの変数](#1-デフォルト値付きの変数) | 宣言時に初期値を設定して NULL を防ぐ |
| 3 | [定数 (CONSTANT)](#2-定数-constant) | `CONSTANT` で再代入不可の値を定義する |
| 4 | [SELECT INTO による変数への代入](#3-select-into-による変数への代入) | クエリ結果を変数に格納する |
| 5 | [%TYPE による型の参照](#4-type-による型の参照) | カラムと同じ型の変数を宣言する |
| 6 | [%ROWTYPE による行型の変数](#5-rowtype-による行型の変数) | テーブルの 1 行をまるごと変数に格納する |
| 7 | [RECORD 型](#6-record-型) | 任意のクエリ結果を受け取る汎用型 |
| 8 | [FOUND 変数](#7-found-変数) | 直前の SQL が行を返したかを確認する特殊変数 |

---

## 1. 変数の宣言と代入

**ファイル:** `sql/1-variables/1-declare-assign.sql`

`DECLARE` で変数を宣言し、`:=` で値を代入します。

PL/pgSQL のコードは `DO $$ ... $$;` ブロックの中に書きます。`DECLARE` セクションで変数名と型を宣言し、`BEGIN` 〜 `END` の間で `:=` を使って値を代入します。ここでは `VARCHAR`、`INT`、`BOOLEAN` の 3 種類の基本型を扱います。

```sql
-- ============================================================
-- 変数の宣言と代入
-- ============================================================
-- DECLARE で変数を宣言し、:= で値を代入する

DO $$
DECLARE
    v_name    VARCHAR(100);
    v_count   INT;
    v_active  BOOLEAN;
BEGIN
    v_name   := '開発部';
    v_count  := 42;
    v_active := TRUE;

    RAISE NOTICE '部署名: %, 人数: %, アクティブ: %', v_name, v_count, v_active;
END;
$$;
```

## 2. デフォルト値付きの変数

**ファイル:** `sql/1-variables/2-default-value.sql`

宣言時に `:=` で初期値を設定し、NULL を防ぎます。

`DECLARE` で変数を宣言するとき、同時に `:=` で初期値を与えられます。初期値を設定しない変数は `NULL` になるため、代入し忘れによる予期しない動作を防ぐのに有効です。

```sql
-- ============================================================
-- デフォルト値付きの変数
-- ============================================================
-- 宣言時に := で初期値を設定できる

DO $$
DECLARE
    v_status VARCHAR(20) := 'active';
    v_limit  INT         := 10;
    v_rate   NUMERIC     := 0.08;
BEGIN
    RAISE NOTICE 'ステータス: %, 上限: %, 率: %', v_status, v_limit, v_rate;
END;
$$;
```

## 3. 定数 (CONSTANT)

**ファイル:** `sql/1-variables/3-constant.sql`

`CONSTANT` を付けて再代入不可の定数を宣言します。

`CONSTANT` キーワードを付けた変数は、宣言時に設定した値から変更できなくなります。税率やステータス文字列など、処理中に変わるべきでない値をうっかり上書きすることを防げます。再代入しようとするとコンパイルエラーになります。

```sql
-- ============================================================
-- 定数 (CONSTANT)
-- ============================================================
-- CONSTANT を付けると再代入できない変数になる

DO $$
DECLARE
    C_TAX_RATE CONSTANT NUMERIC := 0.10;
    v_price    NUMERIC := 1000;
    v_total    NUMERIC;
BEGIN
    v_total := v_price * (1 + C_TAX_RATE);
    RAISE NOTICE '税込価格: %', v_total;
END;
$$;
```

## 4. SELECT INTO による変数への代入

**ファイル:** `sql/1-variables/4-select-into.sql`

`SELECT ... INTO` でクエリ結果を変数に格納します。

テーブルからデータを取得して変数に入れる、実務で最も使うパターンです。`SELECT` の列リストと `INTO` の後の変数が左から順に対応します。結果が 0 行の場合は変数に `NULL` が入り、複数行返る場合は先頭行だけが格納されます。

```sql
-- ============================================================
-- SELECT INTO による変数への代入
-- ============================================================
-- クエリ結果を変数に格納する

DO $$
DECLARE
    v_dept_name VARCHAR(100);
    v_emp_count INT;
BEGIN
    -- 部署名を取得
    SELECT name INTO v_dept_name
    FROM departments
    WHERE id = 1;

    -- その部署の従業員数を取得
    SELECT COUNT(*) INTO v_emp_count
    FROM employees
    WHERE department_id = 1;

    RAISE NOTICE '部署: %, 従業員数: %', v_dept_name, v_emp_count;
END;
$$;
```

## 5. %TYPE による型の参照

**ファイル:** `sql/1-variables/5-type.sql`

`%TYPE` でカラムと同じ型の変数を宣言します。

`employees.last_name%TYPE` のように書くと、そのカラムと同じデータ型の変数が宣言されます。テーブル定義で型が変わっても変数側を修正する必要がないため、保守性が高まります。

```sql
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
```

## 6. %ROWTYPE による行型の変数

**ファイル:** `sql/1-variables/6-rowtype.sql`

`%ROWTYPE` でテーブルの 1 行をまるごと変数に格納します。

`employees%ROWTYPE` と書くと、そのテーブルの全カラムを持つ複合型の変数になります。`SELECT * INTO` で 1 行をまるごと受け取り、`v_employee.id` のようにドット記法で各カラムにアクセスできます。カラムが多いテーブルで変数を 1 つずつ宣言する手間を省けます。

```sql
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
```

## 7. RECORD 型

**ファイル:** `sql/1-variables/7-record.sql`

`RECORD` 型で任意のクエリ結果を格納します。

`%ROWTYPE` は特定のテーブルに紐づきますが、`RECORD` はどんなクエリ結果でも受け取れる汎用型です。JOIN や集約を含むクエリの結果など、既存のテーブル構造に一致しない結果を格納するのに便利です。型は実行時に決まるため、値を代入するまでフィールドにアクセスできません。

```sql
-- ============================================================
-- RECORD 型
-- ============================================================
-- 任意のクエリ結果を格納する汎用型
-- %ROWTYPE と違い、どんなクエリ結果でも受け取れる

DO $$
DECLARE
    v_rec RECORD;
BEGIN
    SELECT
        d.name AS dept_name,
        COUNT(e.id) AS emp_count
    INTO v_rec
    FROM departments d
    LEFT JOIN employees e ON d.id = e.department_id
    WHERE d.id = 2
    GROUP BY d.name;

    RAISE NOTICE '部署: %, 人数: %', v_rec.dept_name, v_rec.emp_count;
END;
$$;
```

## 8. FOUND 変数

**ファイル:** `sql/1-variables/8-found.sql`

直前の SQL が行を返したかを `FOUND` で確認します。

`FOUND` は PL/pgSQL が自動的に管理する `BOOLEAN` 型の特殊変数です。直前の `SELECT INTO` が行を返せば `TRUE`、返さなければ `FALSE` になります。「データが見つからなかった場合の処理」を書くときに不可欠です（条件分岐は次の [1-condition](3-condition.md) で学びます）。

```sql
-- ============================================================
-- FOUND 変数
-- ============================================================
-- 直前の SQL 文が行を返したかどうかを真偽値で保持する特殊変数
-- ※ IF 文は次の 1-condition で学ぶため、ここでは値の確認のみ

DO $$
DECLARE
    v_name employees.last_name%TYPE;
BEGIN
    -- 存在する従業員を検索
    SELECT last_name INTO v_name
    FROM employees
    WHERE id = 1;

    RAISE NOTICE '検索結果: %, FOUND: %', v_name, FOUND;

    -- 存在しない従業員を検索
    SELECT last_name INTO v_name
    FROM employees
    WHERE id = 9999;

    RAISE NOTICE '検索結果: %, FOUND: %', v_name, FOUND;
END;
$$;
```

---

← [前へ: RAISE](1-raise.md) | [BASIC_CONTROL](README.md) | [次へ: 条件分岐](3-condition.md) →
