# INSERT

INSERT 文の基本パターンを学びます。

## 1. 単一行の INSERT

**ファイル:** `sql/2-insert/1-single-row.sql`

テーブルに1行だけデータを追加します。

`INSERT INTO テーブル名 (カラム名) VALUES (値)` が最も基本的な INSERT の構文です。カラムリストに指定したカラムに対応する値を `VALUES` 句で渡します。指定しなかったカラムにはデフォルト値（または NULL）が入ります。

```sql
-- 単一行の INSERT
-- 部署を 1 件追加する
INSERT INTO departments (name)
VALUES ('新規事業部');
```

## 2. 全カラム指定の INSERT

**ファイル:** `sql/2-insert/2-all-columns.sql`

全てのカラムを明示的に指定して INSERT します。

カラム名を省略せず全て列挙することで、どのカラムに何の値が入るかが一目で分かり、可読性と安全性が向上します。テーブルにカラムが追加された場合でも、明示的に指定していれば既存の INSERT 文が意図しない影響を受けることを防げます。

```sql
-- 全カラム指定の INSERT
-- 従業員を 1 件追加する
INSERT INTO employees (department_id, last_name, first_name, email, hire_date, is_active)
VALUES (1, '新田', '太郎', 'nitta.taro@example.com', '2026-04-01', TRUE);
```

## 3. 複数行の INSERT

**ファイル:** `sql/2-insert/3-multi-row.sql`

1つの INSERT 文で複数行のデータを一度に追加します。

`VALUES` 句にカンマ区切りで複数の行を記述することで、1回の SQL 実行で複数レコードを挿入できます。行ごとに個別の INSERT 文を発行するよりもネットワークのラウンドトリップが減り、パフォーマンスが向上します。初期データの投入やバッチ処理でよく使われるパターンです。

```sql
-- 複数行の INSERT
-- プロジェクトを一度に複数件追加する
INSERT INTO projects (name, description, status, start_date)
VALUES
    ('新規Webサービス開発', 'BtoC 向け新規サービス', 'planning', '2026-05-01'),
    ('社内ツール改善', '業務効率化ツールのリニューアル', 'planning', '2026-06-01'),
    ('データ分析基盤構築', '全社データの可視化基盤', 'planning', '2026-07-01');
```

## 4. INSERT ... RETURNING

**ファイル:** `sql/2-insert/4-returning.sql`

INSERT した直後に、そのレコードの値を取得します。

`RETURNING` 句を付けると、挿入されたレコードのカラム値を INSERT 文の結果として返すことができます（PostgreSQL 固有の機能）。`SERIAL` や `GENERATED` で自動採番された ID を、別のクエリを発行せずにその場で確認できるため、アプリケーションから連続した処理を行う際に便利です。

```sql
-- INSERT ... RETURNING
-- 追加したレコードの ID を確認する (PostgreSQL 固有)
INSERT INTO departments (name)
VALUES ('研究開発部')
RETURNING id, name;
```

## 5. INSERT ... SELECT

**ファイル:** `sql/2-insert/5-insert-select.sql`

別テーブルのクエリ結果をそのまま挿入します。

`INSERT INTO ... SELECT ...` の構文を使うと、`VALUES` の代わりに SELECT 文の結果を挿入データとして利用できます。既存データの複製、テーブル間のデータ移行、条件に基づく一括登録など、複数行を動的に生成して挿入したい場面で有効です。SELECT 文には `WHERE`、`JOIN`、サブクエリなど通常の SELECT で使える機能を全て利用できます。

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

## 6. INSERT ... ON CONFLICT (UPSERT)

**ファイル:** `sql/2-insert/6-on-conflict.sql`

UNIQUE 制約に違反した場合の挙動を制御します。

`ON CONFLICT` 句を使うと、INSERT 時に UNIQUE 制約やプライマリキーの重複が発生した場合の処理を指定できます。`DO NOTHING` で挿入をスキップし、`DO UPDATE SET ...` で既存レコードを更新できます。この「INSERT するか、既存なら UPDATE する」パターンは UPSERT と呼ばれ、冪等な処理を実現するのに便利です。`EXCLUDED` は挿入しようとした値を参照する特別なテーブル参照です。

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

## 7. デフォルト値の利用

**ファイル:** `sql/2-insert/7-default-values.sql`

`DEFAULT` キーワードを使い、テーブル定義のデフォルト値を利用します。

`VALUES` 句の中で値の代わりに `DEFAULT` と書くと、そのカラムにはテーブル定義時に設定されたデフォルト値が適用されます。カラムリストからカラムを省略してもデフォルト値は使われますが、`DEFAULT` を明示的に書くことで「意図的にデフォルト値を選択した」ことが読み手に伝わります。`RETURNING` と組み合わせると、実際に挿入されたデフォルト値をすぐに確認できます。

```sql
-- デフォルト値の利用
-- DEFAULT を明示的に指定して INSERT する
INSERT INTO tasks (project_id, title, status, priority)
VALUES (1, '確認テスト用タスク', DEFAULT, DEFAULT)
RETURNING id, title, status, priority;
```

---

← [前へ: SELECT 応用](2-advanced-select.md) | [BASIC](README.md) | [次へ: UPDATE](4-update.md) →
