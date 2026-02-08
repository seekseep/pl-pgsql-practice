# SELECT

SELECT 文の基本パターンを学びます。

## 0. 全件取得

**ファイル:** `sql/0-select/0-select-all.sql`

`SELECT *` を使ってテーブルの全レコード・全カラムを取得する最も基本的なクエリです。

```sql
-- 全件取得
-- departments テーブルの全レコードを取得する
SELECT * FROM departments;
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/0-select/0-select-all.sql
```

## 1. カラム指定

**ファイル:** `sql/0-select/1-select-columns.sql`

必要なカラムだけを明示的に指定して取得する方法を示します。不要なデータを読み込まないため、パフォーマンスの向上にもつながります。

```sql
-- カラム指定
-- 必要なカラムだけを指定して取得する
SELECT id, last_name, first_name, email
FROM employees;
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/0-select/1-select-columns.sql
```

## 2. WHERE による絞り込み

**ファイル:** `sql/0-select/2-where.sql`

`WHERE` 句を使って条件に合致するレコードだけを取得する方法を示します。ここでは在籍中の従業員のみを絞り込んでいます。

```sql
-- WHERE による絞り込み
-- 在籍中の従業員のみ取得する
SELECT id, last_name, first_name, email
FROM employees
WHERE is_active = TRUE;
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/0-select/2-where.sql
```

## 3. 比較演算子

**ファイル:** `sql/0-select/3-comparison-operators.sql`

`>=` などの比較演算子を使って、日付や数値の範囲で絞り込む方法を示します。

```sql
-- 比較演算子
-- 2025年7月以降に入社した従業員を取得する
SELECT id, last_name, first_name, hire_date
FROM employees
WHERE hire_date >= '2025-07-01';
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/0-select/3-comparison-operators.sql
```

## 4. LIKE による部分一致検索

**ファイル:** `sql/0-select/4-like.sql`

`LIKE` 演算子とワイルドカード `%` を使って、文字列の部分一致検索を行う方法を示します。

```sql
-- LIKE による部分一致検索
-- 姓が「田」で終わる従業員を取得する
SELECT id, last_name, first_name
FROM employees
WHERE last_name LIKE '%田';
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/0-select/4-like.sql
```

## 5. IN による複数値指定

**ファイル:** `sql/0-select/5-in.sql`

`IN` 句を使って、複数の値のいずれかに一致するレコードを取得する方法を示します。

```sql
-- IN による複数値指定
-- ステータスが active または planning のプロジェクトを取得する
SELECT id, name, status
FROM projects
WHERE status IN ('active', 'planning');
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/0-select/5-in.sql
```

## 6. BETWEEN による範囲指定

**ファイル:** `sql/0-select/6-between.sql`

`BETWEEN` を使って、指定した範囲内の値を持つレコードを取得する方法を示します。日付や数値の範囲検索に便利です。

```sql
-- BETWEEN による範囲指定
-- 2025年上半期に入社した従業員を取得する
SELECT id, last_name, first_name, hire_date
FROM employees
WHERE hire_date BETWEEN '2025-01-01' AND '2025-06-30';
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/0-select/6-between.sql
```

## 7. IS NULL / IS NOT NULL

**ファイル:** `sql/0-select/7-is-null.sql`

`IS NULL` を使って、値が設定されていない（NULL の）レコードを検索する方法を示します。

```sql
-- IS NULL / IS NOT NULL
-- 担当者が未割り当てのタスクを取得する
SELECT id, title, status
FROM tasks
WHERE assignee_id IS NULL;
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/0-select/7-is-null.sql
```

## 8. ORDER BY によるソート

**ファイル:** `sql/0-select/8-order-by.sql`

`ORDER BY` 句を使って、取得結果を特定のカラムで並び替える方法を示します。`DESC` で降順になります。

```sql
-- ORDER BY によるソート
-- 従業員を入社日の新しい順に取得する
SELECT id, last_name, first_name, hire_date
FROM employees
ORDER BY hire_date DESC;
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/0-select/8-order-by.sql
```

## 9. LIMIT / OFFSET によるページング

**ファイル:** `sql/0-select/9-limit-offset.sql`

`LIMIT` と `OFFSET` を組み合わせて、取得件数の制限とページネーションを実現する方法を示します。

```sql
-- LIMIT / OFFSET によるページング
-- 先頭 10 件を取得する
SELECT id, last_name, first_name
FROM employees
ORDER BY id
LIMIT 10;

-- 11件目から10件取得する (2ページ目)
SELECT id, last_name, first_name
FROM employees
ORDER BY id
LIMIT 10 OFFSET 10;
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/0-select/9-limit-offset.sql
```

## 10. DISTINCT による重複排除

**ファイル:** `sql/0-select/10-distinct.sql`

`DISTINCT` を使って、重複する値を除外してユニークな結果のみを取得する方法を示します。

```sql
-- DISTINCT による重複排除
-- タスクに存在するステータスの一覧を取得する
SELECT DISTINCT status FROM tasks;
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/0-select/10-distinct.sql
```

## 11. 集約関数 (COUNT, SUM, AVG, MAX, MIN)

**ファイル:** `sql/0-select/11-aggregate-functions.sql`

`COUNT` などの集約関数と `GROUP BY` を組み合わせて、グループごとの集計を行う方法を示します。

```sql
-- 集約関数 (COUNT, SUM, AVG, MAX, MIN)
-- 従業員の総数を取得する
SELECT COUNT(*) AS total_employees FROM employees;

-- 部署ごとの従業員数を取得する
SELECT department_id, COUNT(*) AS employee_count
FROM employees
GROUP BY department_id;
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/0-select/11-aggregate-functions.sql
```

## 12. HAVING による集約結果の絞り込み

**ファイル:** `sql/0-select/12-having.sql`

`HAVING` 句を使って、`GROUP BY` で集約した結果に対して条件を指定する方法を示します。`WHERE` がグループ化前、`HAVING` がグループ化後の絞り込みです。

```sql
-- HAVING による集約結果の絞り込み
-- 従業員が 10 人以上の部署を取得する
SELECT department_id, COUNT(*) AS employee_count
FROM employees
GROUP BY department_id
HAVING COUNT(*) >= 10;
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/0-select/12-having.sql
```

## 13. INNER JOIN

**ファイル:** `sql/0-select/13-inner-join.sql`

`INNER JOIN` を使って、2つのテーブルを結合し、両方に一致するレコードのみを取得する方法を示します。

```sql
-- INNER JOIN
-- 従業員と所属部署名を結合して取得する
SELECT
    e.id,
    e.last_name,
    e.first_name,
    d.name AS department_name
FROM employees e
INNER JOIN departments d ON e.department_id = d.id;
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/0-select/13-inner-join.sql
```

## 14. LEFT JOIN

**ファイル:** `sql/0-select/14-left-join.sql`

`LEFT JOIN` を使って、左側テーブルの全レコードを保持しつつ右側テーブルと結合する方法を示します。一致しない場合は NULL になります。

```sql
-- LEFT JOIN
-- プロジェクトごとのタスク数を取得する (タスクがないプロジェクトも含む)
SELECT
    p.id,
    p.name AS project_name,
    COUNT(t.id) AS task_count
FROM projects p
LEFT JOIN tasks t ON p.id = t.project_id
GROUP BY p.id, p.name
ORDER BY task_count DESC;
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/0-select/14-left-join.sql
```

## 15. 複数テーブルの JOIN

**ファイル:** `sql/0-select/15-multi-join.sql`

3つ以上のテーブルを `JOIN` で結合して、関連データをまとめて取得する方法を示します。

```sql
-- 複数テーブルの JOIN
-- プロジェクトメンバーの一覧を取得する
SELECT
    e.last_name || ' ' || e.first_name AS employee_name,
    p.name AS project_name,
    pm.role
FROM project_members pm
INNER JOIN employees e ON pm.employee_id = e.id
INNER JOIN projects p ON pm.project_id = p.id
ORDER BY p.name, pm.role;
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/0-select/15-multi-join.sql
```

## 16. サブクエリ (WHERE 句)

**ファイル:** `sql/0-select/16-subquery-where.sql`

`WHERE` 句の中にサブクエリを使用して、別テーブルの値を条件に絞り込む方法を示します。

```sql
-- サブクエリ (WHERE 句)
-- 開発部に所属する従業員を取得する
SELECT id, last_name, first_name
FROM employees
WHERE department_id = (
    SELECT id FROM departments WHERE name = '開発部'
);
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/0-select/16-subquery-where.sql
```

## 17. サブクエリ (IN)

**ファイル:** `sql/0-select/17-subquery-in.sql`

`IN` の中にサブクエリを使用して、複数の結果に一致するレコードを取得する方法を示します。

```sql
-- サブクエリ (IN)
-- active なプロジェクトに参加している従業員を取得する
SELECT DISTINCT e.id, e.last_name, e.first_name
FROM employees e
WHERE e.id IN (
    SELECT pm.employee_id
    FROM project_members pm
    INNER JOIN projects p ON pm.project_id = p.id
    WHERE p.status = 'active'
);
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/0-select/17-subquery-in.sql
```

## 18. EXISTS

**ファイル:** `sql/0-select/18-exists.sql`

`EXISTS` を使って、相関サブクエリの結果が存在するかどうかで絞り込む方法を示します。`IN` よりも大量データに対して効率的な場合があります。

```sql
-- EXISTS
-- プロジェクトに 1 つ以上参加している従業員を取得する
SELECT e.id, e.last_name, e.first_name
FROM employees e
WHERE EXISTS (
    SELECT 1 FROM project_members pm WHERE pm.employee_id = e.id
);
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/0-select/18-exists.sql
```

## 19. CASE 式

**ファイル:** `sql/0-select/19-case.sql`

`CASE` 式を使って、条件に応じた値の変換や表示ラベルの切り替えを行う方法を示します。`ORDER BY` 内でも利用できます。

```sql
-- CASE 式
-- タスクの優先度を日本語で表示する
SELECT
    id,
    title,
    CASE priority
        WHEN 'urgent' THEN '緊急'
        WHEN 'high'   THEN '高'
        WHEN 'medium' THEN '中'
        WHEN 'low'    THEN '低'
    END AS priority_label,
    status
FROM tasks
ORDER BY
    CASE priority
        WHEN 'urgent' THEN 1
        WHEN 'high'   THEN 2
        WHEN 'medium' THEN 3
        WHEN 'low'    THEN 4
    END;
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/0-select/19-case.sql
```

## 20. 集約 + CASE (クロス集計)

**ファイル:** `sql/0-select/20-aggregate-case.sql`

`COUNT` と `CASE` を組み合わせて、クロス集計（ピボット）を行う方法を示します。行と列の両方向で集計できます。

```sql
-- 集約 + CASE (クロス集計)
-- プロジェクトごとにステータス別のタスク数を集計する
SELECT
    p.name AS project_name,
    COUNT(*) AS total,
    COUNT(CASE WHEN t.status = 'todo' THEN 1 END) AS todo,
    COUNT(CASE WHEN t.status = 'in_progress' THEN 1 END) AS in_progress,
    COUNT(CASE WHEN t.status = 'in_review' THEN 1 END) AS in_review,
    COUNT(CASE WHEN t.status = 'done' THEN 1 END) AS done
FROM projects p
INNER JOIN tasks t ON p.id = t.project_id
GROUP BY p.id, p.name
ORDER BY p.name;
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/0-select/20-aggregate-case.sql
```

---

[BASIC](README.md) | [次へ: INSERT](1-insert.md) →
