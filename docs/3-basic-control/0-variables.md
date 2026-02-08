# 変数

> ※ このセクションでは IF・ループ・カーソル・例外処理は使いません

## 0. 変数の宣言と代入

**ファイル:** `sql/0-variables/0-declare-assign.sql`

`DECLARE` ブロックで変数を宣言し、`:=` 演算子で値を代入する基本的な方法を示します。`VARCHAR`、`INT`、`BOOLEAN` の 3 種類の型を扱っています。

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

### 実行方法

> GUI ツール（pgAdmin, DBeaver 等）では、上記の SQL をクエリエディタに貼り付けて実行できます。

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/3-basic-control/sql/0-variables/0-declare-assign.sql
```

## 1. デフォルト値付きの変数

**ファイル:** `sql/0-variables/1-default-value.sql`

変数の宣言時に `:=` で初期値を設定する方法を示します。宣言と同時にデフォルト値を設定することで、代入忘れによる NULL を防げます。

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

### 実行方法

> GUI ツール（pgAdmin, DBeaver 等）では、上記の SQL をクエリエディタに貼り付けて実行できます。

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/3-basic-control/sql/0-variables/1-default-value.sql
```

## 2. 定数 (CONSTANT)

**ファイル:** `sql/0-variables/2-constant.sql`

`CONSTANT` キーワードを付けて再代入不可の定数を宣言する方法を示します。税率のような変更されるべきでない値に使います。

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

### 実行方法

> GUI ツール（pgAdmin, DBeaver 等）では、上記の SQL をクエリエディタに貼り付けて実行できます。

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/3-basic-control/sql/0-variables/2-constant.sql
```

## 3. SELECT INTO による変数への代入

**ファイル:** `sql/0-variables/3-select-into.sql`

`SELECT ... INTO` を使ってクエリ結果を変数に格納する方法を示します。テーブルからデータを取得して変数に代入する、実務で頻出するパターンです。

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

### 実行方法

> GUI ツール（pgAdmin, DBeaver 等）では、上記の SQL をクエリエディタに貼り付けて実行できます。

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/3-basic-control/sql/0-variables/3-select-into.sql
```

## 4. %TYPE による型の参照

**ファイル:** `sql/0-variables/4-type.sql`

`%TYPE` を使ってテーブルのカラムと同じ型の変数を宣言する方法を示します。カラムの型が変わっても変数の型が自動的に追従するため、保守性が高まります。

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

### 実行方法

> GUI ツール（pgAdmin, DBeaver 等）では、上記の SQL をクエリエディタに貼り付けて実行できます。

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/3-basic-control/sql/0-variables/4-type.sql
```

## 5. %ROWTYPE による行型の変数

**ファイル:** `sql/0-variables/5-rowtype.sql`

`%ROWTYPE` を使ってテーブルの 1 行をまるごと変数に格納する方法を示します。`SELECT *` の結果をそのまま受け取り、各カラムにドット記法でアクセスできます。

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

### 実行方法

> GUI ツール（pgAdmin, DBeaver 等）では、上記の SQL をクエリエディタに貼り付けて実行できます。

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/3-basic-control/sql/0-variables/5-rowtype.sql
```

## 6. RECORD 型

**ファイル:** `sql/0-variables/6-record.sql`

`RECORD` 型を使って任意のクエリ結果を格納する方法を示します。`%ROWTYPE` と違い、どんなクエリ結果でも受け取れる汎用的な型です。

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

### 実行方法

> GUI ツール（pgAdmin, DBeaver 等）では、上記の SQL をクエリエディタに貼り付けて実行できます。

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/3-basic-control/sql/0-variables/6-record.sql
```

## 7. FOUND 変数

**ファイル:** `sql/0-variables/7-found.sql`

`FOUND` 特殊変数を使って直前の SQL 文が行を返したかどうかを確認する方法を示します。存在するレコードと存在しないレコードを検索して `FOUND` の値の変化を確認します。

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

### 実行方法

> GUI ツール（pgAdmin, DBeaver 等）では、上記の SQL をクエリエディタに貼り付けて実行できます。

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/3-basic-control/sql/0-variables/7-found.sql
```

---

[BASIC_CONTROL](README.md) | [次へ: 条件分岐](1-condition.md) →
