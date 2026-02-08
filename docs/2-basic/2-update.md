# UPDATE

UPDATE 文の基本パターンを学びます。

## 0. 単純な UPDATE

**ファイル:** `sql/2-update/0-simple-update.sql`

`UPDATE ... SET ... WHERE` を使って、特定のレコードのカラム値を変更する最も基本的な方法を示します。

```sql
-- 単純な UPDATE
-- 部署名を変更する
UPDATE departments
SET name = '第一開発部', updated_at = CURRENT_TIMESTAMP
WHERE id = 2;
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/2-update/0-simple-update.sql
```

## 1. 複数カラムの UPDATE

**ファイル:** `sql/2-update/1-multi-column.sql`

1つの `UPDATE` 文で複数のカラムを同時に更新する方法を示します。部署異動のように関連する変更をまとめて行えます。

```sql
-- 複数カラムの UPDATE
-- 従業員の部署異動を行う
UPDATE employees
SET
    department_id = 3,
    updated_at = CURRENT_TIMESTAMP
WHERE id = 1;
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/2-update/1-multi-column.sql
```

## 2. 条件付き UPDATE

**ファイル:** `sql/2-update/2-conditional.sql`

`WHERE` 句で対象を限定して更新する方法を示します。ここでは特定の従業員を非アクティブにする退職処理を行っています。

```sql
-- 条件付き UPDATE
-- 退職処理: 特定の従業員を非アクティブにする
UPDATE employees
SET
    is_active = FALSE,
    updated_at = CURRENT_TIMESTAMP
WHERE id = 5;
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/2-update/2-conditional.sql
```

## 3. 複数行の UPDATE

**ファイル:** `sql/2-update/3-multi-row.sql`

`WHERE` の条件に合致する複数のレコードを一括で更新する方法を示します。ステータスの一括変更などに利用できます。

```sql
-- 複数行の UPDATE
-- 完了済みプロジェクトのステータスを archived に変更する
UPDATE projects
SET
    status = 'archived',
    updated_at = CURRENT_TIMESTAMP
WHERE status = 'completed';
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/2-update/3-multi-row.sql
```

## 4. CASE を使った条件付き UPDATE

**ファイル:** `sql/2-update/4-case-update.sql`

`CASE` 式を `SET` 句の中で使い、行ごとに異なる値で更新する方法を示します。条件に応じた一括変更が1つのクエリで実現できます。

```sql
-- CASE を使った条件付き UPDATE
-- タスクの優先度を一括で見直す
UPDATE tasks
SET
    priority = CASE
        WHEN priority = 'urgent' THEN 'high'
        WHEN priority = 'low'    THEN 'medium'
        ELSE priority
    END,
    updated_at = CURRENT_TIMESTAMP
WHERE priority IN ('urgent', 'low');
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/2-update/4-case-update.sql
```

## 5. サブクエリを使った UPDATE

**ファイル:** `sql/2-update/5-subquery.sql`

`WHERE` 句にサブクエリを使って、別テーブルの情報を条件に更新対象を絞り込む方法を示します。

```sql
-- サブクエリを使った UPDATE
-- 開発部の全従業員のタスクを in_progress に変更する
UPDATE tasks
SET
    status = 'in_progress',
    updated_at = CURRENT_TIMESTAMP
WHERE assignee_id IN (
    SELECT id FROM employees
    WHERE department_id = (
        SELECT id FROM departments WHERE name = '開発部'
    )
)
AND status = 'todo';
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/2-update/5-subquery.sql
```

## 6. FROM を使った UPDATE

**ファイル:** `sql/2-update/6-from-update.sql`

PostgreSQL 固有の `UPDATE ... FROM` 構文を使って、別テーブルと結合しながら更新する方法を示します。サブクエリよりも直感的に書ける場合があります。

```sql
-- FROM を使った UPDATE (PostgreSQL 固有)
-- active プロジェクトの未完了タスクの期限を 7 日延長する
UPDATE tasks
SET
    due_date = tasks.due_date + INTERVAL '7 days',
    updated_at = CURRENT_TIMESTAMP
FROM projects p
WHERE tasks.project_id = p.id
  AND p.status = 'active'
  AND tasks.status != 'done'
  AND tasks.due_date IS NOT NULL;
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/2-update/6-from-update.sql
```

## 7. UPDATE ... RETURNING

**ファイル:** `sql/2-update/7-returning.sql`

`RETURNING` 句を使って、更新後のレコードの値を即座に取得する方法を示します（PostgreSQL 固有）。更新結果の確認に便利です。

```sql
-- UPDATE ... RETURNING
-- 更新結果を確認しながら UPDATE する (PostgreSQL 固有)
UPDATE employees
SET
    is_active = FALSE,
    updated_at = CURRENT_TIMESTAMP
WHERE id = 10
RETURNING id, last_name, first_name, is_active;
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/2-update/7-returning.sql
```

---

← [前へ: INSERT](1-insert.md) | [BASIC](README.md) | [次へ: DELETE](3-delete.md) →
