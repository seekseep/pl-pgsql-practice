# INSERT

INSERT 文の基本パターンを学びます。

## 0. 単一行の INSERT

**ファイル:** `sql/1-insert/0-single-row.sql`

`INSERT INTO ... VALUES` を使って、テーブルに1行だけデータを追加する最も基本的な方法を示します。

```sql
-- 単一行の INSERT
-- 部署を 1 件追加する
INSERT INTO departments (name)
VALUES ('新規事業部');
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/1-insert/0-single-row.sql
```

## 1. 全カラム指定の INSERT

**ファイル:** `sql/1-insert/1-all-columns.sql`

全てのカラムを明示的に指定して INSERT する方法を示します。カラム名を省略せず書くことで可読性と安全性が向上します。

```sql
-- 全カラム指定の INSERT
-- 従業員を 1 件追加する
INSERT INTO employees (department_id, last_name, first_name, email, hire_date, is_active)
VALUES (1, '新田', '太郎', 'nitta.taro@example.com', '2026-04-01', TRUE);
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/1-insert/1-all-columns.sql
```

## 2. 複数行の INSERT

**ファイル:** `sql/1-insert/2-multi-row.sql`

1つの `INSERT` 文で複数行のデータを一度に追加する方法を示します。個別に INSERT するよりも効率的です。

```sql
-- 複数行の INSERT
-- プロジェクトを一度に複数件追加する
INSERT INTO projects (name, description, status, start_date)
VALUES
    ('新規Webサービス開発', 'BtoC 向け新規サービス', 'planning', '2026-05-01'),
    ('社内ツール改善', '業務効率化ツールのリニューアル', 'planning', '2026-06-01'),
    ('データ分析基盤構築', '全社データの可視化基盤', 'planning', '2026-07-01');
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/1-insert/2-multi-row.sql
```

## 3. INSERT ... RETURNING

**ファイル:** `sql/1-insert/3-returning.sql`

`RETURNING` 句を使って、INSERT した直後にそのレコードの値を取得する方法を示します。自動採番された ID の確認などに便利です（PostgreSQL 固有）。

```sql
-- INSERT ... RETURNING
-- 追加したレコードの ID を確認する (PostgreSQL 固有)
INSERT INTO departments (name)
VALUES ('研究開発部')
RETURNING id, name;
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/1-insert/3-returning.sql
```

## 4. INSERT ... SELECT

**ファイル:** `sql/1-insert/4-insert-select.sql`

`INSERT ... SELECT` を使って、別テーブルのクエリ結果をそのまま挿入する方法を示します。データの複製や移行に便利です。

```sql
-- INSERT ... SELECT
-- active プロジェクトの最初のメンバーを新規プロジェクトにもコピーする
INSERT INTO project_members (project_id, employee_id, role, joined_at)
SELECT
    21,
    pm.employee_id,
    'member',
    CURRENT_DATE
FROM project_members pm
INNER JOIN projects p ON pm.project_id = p.id
WHERE p.status = 'active'
  AND pm.project_id = (
      SELECT id FROM projects WHERE status = 'active' ORDER BY id LIMIT 1
  )
ON CONFLICT (project_id, employee_id) DO NOTHING;
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/1-insert/4-insert-select.sql
```

## 5. INSERT ... ON CONFLICT (UPSERT)

**ファイル:** `sql/1-insert/5-on-conflict.sql`

`ON CONFLICT` 句を使って、UNIQUE 制約に違反した場合の挙動を制御する方法を示します。`DO NOTHING` で無視、`DO UPDATE` で更新を行えます。

```sql
-- INSERT ... ON CONFLICT (UPSERT)
-- 既にメンバーがいる場合は何もしない (UNIQUE 制約を利用)
INSERT INTO project_members (project_id, employee_id, role, joined_at)
VALUES (1, 1, 'reviewer', CURRENT_DATE)
ON CONFLICT (project_id, employee_id) DO NOTHING;

-- 既にメンバーがいる場合は役割を更新する
INSERT INTO project_members (project_id, employee_id, role, joined_at)
VALUES (1, 1, 'manager', CURRENT_DATE)
ON CONFLICT (project_id, employee_id)
DO UPDATE SET
    role = EXCLUDED.role,
    updated_at = CURRENT_TIMESTAMP;
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/1-insert/5-on-conflict.sql
```

## 6. デフォルト値の利用

**ファイル:** `sql/1-insert/6-default-values.sql`

`DEFAULT` キーワードを明示的に指定して、テーブル定義のデフォルト値を利用する方法を示します。

```sql
-- デフォルト値の利用
-- DEFAULT を明示的に指定して INSERT する
INSERT INTO tasks (project_id, title, status, priority)
VALUES (1, '確認テスト用タスク', DEFAULT, DEFAULT)
RETURNING id, title, status, priority;
```

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/1-insert/6-default-values.sql
```

---

← [前へ: SELECT](0-select.md) | [BASIC](README.md) | [次へ: UPDATE](2-update.md) →
