# DELETE

DELETE 文の基本パターンを学びます。

## 0. 単純な DELETE

**ファイル:** `sql/3-delete/0-simple-delete.sql`

`DELETE FROM ... WHERE` を使って、特定のレコードを1件削除する最も基本的な方法を示します。

```sql
-- 単純な DELETE
-- 特定のジョブログを削除する
DELETE FROM job_logs
WHERE id = 1;
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/3-delete/0-simple-delete.sql
```

## 1. 条件付き DELETE

**ファイル:** `sql/3-delete/1-conditional.sql`

`WHERE` 句で条件を指定して、該当する複数のレコードを削除する方法を示します。

```sql
-- 条件付き DELETE
-- 失敗したジョブログを削除する
DELETE FROM job_logs
WHERE status = 'failure';
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/3-delete/1-conditional.sql
```

## 2. 日付条件による DELETE

**ファイル:** `sql/3-delete/2-date-condition.sql`

日付の比較を条件にして、古いレコードを削除する方法を示します。ログデータのクリーンアップなどに利用できます。

```sql
-- 日付条件による DELETE
-- 2025年1月より前のジョブログを削除する
DELETE FROM job_logs
WHERE started_at < '2025-01-01';
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/3-delete/2-date-condition.sql
```

## 3. サブクエリを使った DELETE

**ファイル:** `sql/3-delete/3-subquery.sql`

`WHERE ... IN (サブクエリ)` を使って、別テーブルの条件に基づいてレコードを削除する方法を示します。

```sql
-- サブクエリを使った DELETE
-- 無効化されたジョブのログを全て削除する
DELETE FROM job_logs
WHERE job_id IN (
    SELECT id FROM jobs WHERE is_enabled = FALSE
);
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/3-delete/3-subquery.sql
```

## 4. EXISTS を使った DELETE

**ファイル:** `sql/3-delete/4-exists.sql`

`EXISTS` を使って、相関サブクエリの結果に基づいてレコードを削除する方法を示します。関連テーブルの状態に応じた削除に便利です。

```sql
-- EXISTS を使った DELETE
-- archived プロジェクトの全タスクを削除する
DELETE FROM tasks
WHERE EXISTS (
    SELECT 1 FROM projects p
    WHERE p.id = tasks.project_id
      AND p.status = 'archived'
);
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/3-delete/4-exists.sql
```

## 5. DELETE ... RETURNING

**ファイル:** `sql/3-delete/5-returning.sql`

`RETURNING` 句を使って、削除したレコードの内容を確認する方法を示します（PostgreSQL 固有）。削除前のデータを記録したい場合に便利です。

```sql
-- DELETE ... RETURNING
-- 削除したレコードの内容を確認する (PostgreSQL 固有)
DELETE FROM job_logs
WHERE id = 2
RETURNING id, job_id, status, message;
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/3-delete/5-returning.sql
```

## 6. USING を使った DELETE

**ファイル:** `sql/3-delete/6-using.sql`

PostgreSQL 固有の `DELETE ... USING` 構文を使って、別テーブルと結合しながら削除する方法を示します。サブクエリよりも簡潔に書ける場合があります。

```sql
-- USING を使った DELETE (PostgreSQL 固有)
-- completed プロジェクトのメンバーを削除する
DELETE FROM project_members
USING projects p
WHERE project_members.project_id = p.id
  AND p.status = 'completed';
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/3-delete/6-using.sql
```

## 7. TRUNCATE (全件削除)

**ファイル:** `sql/3-delete/7-truncate.sql`

`TRUNCATE` を使って、テーブルの全レコードを高速に削除する方法を示します。`DELETE` よりも高速ですが、WHERE 句が使えないため注意が必要です。

```sql
-- TRUNCATE (全件削除)
-- テーブルの全レコードを高速に削除する
-- ※ 注意: WHERE 句は使えず、ロールバックも難しい
-- TRUNCATE TABLE job_logs;

-- CASCADE 付きで関連テーブルも含めて全削除する場合:
-- TRUNCATE TABLE projects CASCADE;
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/3-delete/7-truncate.sql
```

---

← [前へ: UPDATE](2-update.md) | [BASIC](README.md)
