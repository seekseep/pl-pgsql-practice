# SELECT 基礎

単一テーブルに対する基本的な SELECT 文のパターンを学びます。

## 1. 全件取得

**ファイル:** `sql/1-select/1-select-all.sql`

テーブルの全データを取得します。

`SELECT *` を使うと、指定したテーブルの全レコード・全カラムをまとめて取得できます。テーブルの中身を素早く確認したいときに便利ですが、カラム数やレコード数が多い本番環境では必要なカラムだけを指定する方が効率的です。

```sql
-- 全件取得
-- departments テーブルの全レコードを取得する
SELECT * FROM departments;
```

## 2. カラム指定

**ファイル:** `sql/1-select/2-select-columns.sql`

必要なカラムだけを指定して取得します。

`SELECT *` の代わりに、取得したいカラム名をカンマ区切りで明示的に列挙します。不要なデータを読み込まないためネットワーク転送量やメモリ使用量が減り、パフォーマンスの向上にもつながります。また、コードの可読性が上がり、テーブル構造の変更にも影響を受けにくくなります。

```sql
-- カラム指定
-- 必要なカラムだけを指定して取得する
SELECT id, last_name, first_name, email
FROM employees;
```

## 3. WHERE による絞り込み

**ファイル:** `sql/1-select/3-where.sql`

条件に合致するレコードだけを取得します。

`WHERE` 句を使うと、指定した条件を満たすレコードだけに結果を絞り込めます。条件にはカラム名と値の比較を記述し、`=`、`!=`、`<`、`>` などの演算子が使えます。ここではブール型カラム `is_active` が `TRUE` であるレコードのみを取得しています。

```sql
-- WHERE による絞り込み
-- 在籍中の従業員のみ取得する
SELECT id, last_name, first_name, email
FROM employees
WHERE is_active = TRUE;
```

## 4. 比較演算子

**ファイル:** `sql/1-select/4-comparison-operators.sql`

比較演算子を使って範囲や大小で絞り込みます。

`=` 以外にも `>=`、`<=`、`<>`（不等号）などの比較演算子を `WHERE` 句で使用できます。日付型カラムに対しても文字列リテラル（`'2025-07-01'`）との比較が可能で、特定の日付以降・以前といった範囲指定に活用できます。

| 演算子 | 意味 | 例 |
|---|---|---|
| `=` | 等しい | `status = 'active'` |
| `<>` / `!=` | 等しくない | `status <> 'done'` |
| `<` | より小さい | `hire_date < '2025-01-01'` |
| `>` | より大きい | `hire_date > '2025-01-01'` |
| `<=` | 以下 | `priority <= 3` |
| `>=` | 以上 | `hire_date >= '2025-07-01'` |

```sql
-- 比較演算子
-- 2025年7月以降に入社した従業員を取得する
SELECT id, last_name, first_name, hire_date
FROM employees
WHERE hire_date >= '2025-07-01';
```

## 5. LIKE による部分一致検索

**ファイル:** `sql/1-select/5-like.sql`

ワイルドカードを使って文字列の部分一致検索を行います。

`LIKE` 演算子は文字列パターンに基づく検索を提供します。`%` は任意の0文字以上の文字列、`_` は任意の1文字にマッチします。たとえば `'%田'` は「田」で終わる全ての文字列に一致します。大文字・小文字を区別しない場合は `ILIKE` を使います。

| 名称 | パターン | 一致する | 一致しない |
|---|---|---|---|
| 前方一致 | `'田%'` | `田中`, `田` | `山田`, `内田` |
| 後方一致 | `'%田'` | `山田`, `内田` | `田中`, `田辺` |
| 部分一致 | `'%田%'` | `山田`, `田中`, `内田原` | `佐藤`, `鈴木` |
| 1文字ワイルドカード | `'田_'` | `田中`, `田辺` | `田`, `田中島` |
| 組み合わせ | `'_田%'` | `内田`, `山田太郎` | `田中`, `佐々木田` |

```sql
-- LIKE による部分一致検索
-- 姓が「田」で終わる従業員を取得する
SELECT id, last_name, first_name
FROM employees
WHERE last_name LIKE '%田';
```

## 6. IN による複数値指定

**ファイル:** `sql/1-select/6-in.sql`

複数の値のいずれかに一致するレコードを取得します。

`IN` 句を使うと、カラムの値が指定したリストのいずれかに一致するかを簡潔に記述できます。`OR` を複数書く代わりに使えるため、可読性が高くなります。リストの要素数に制限はありませんが、大量の値を指定する場合はサブクエリとの組み合わせが有効です。

```sql
-- IN による複数値指定
-- ステータスが active または planning のプロジェクトを取得する
SELECT id, name, status
FROM projects
WHERE status IN ('active', 'planning');
```

## 7. BETWEEN による範囲指定

**ファイル:** `sql/1-select/7-between.sql`

開始値と終了値を指定して範囲検索を行います。

`BETWEEN A AND B` は `>= A AND <= B` と同等で、両端の値を含みます。日付・数値・文字列など比較可能な型に対して使え、特に期間指定の検索で直感的に記述できます。

```sql
-- BETWEEN による範囲指定
-- 2025年上半期に入社した従業員を取得する
SELECT id, last_name, first_name, hire_date
FROM employees
WHERE hire_date BETWEEN '2025-01-01' AND '2025-06-30';
```

## 8. IS NULL / IS NOT NULL

**ファイル:** `sql/1-select/8-is-null.sql`

NULL（値なし）のレコードを検索します。

SQL では NULL は「値が存在しない」ことを意味し、`= NULL` では判定できません。NULL の判定には必ず `IS NULL` または `IS NOT NULL` を使います。NULL を含むカラムでの `WHERE` 条件は、この構文を使わないと意図しない結果になるため注意が必要です。

```sql
-- IS NULL / IS NOT NULL
-- 担当者が未割り当てのタスクを取得する
SELECT id, title, status
FROM tasks
WHERE assignee_id IS NULL;
```

## 9. COALESCE による NULL 置換

**ファイル:** `sql/1-select/9-coalesce.sql`

NULL を指定したデフォルト値に置き換えて表示します。

`COALESCE(値1, 値2, ...)` は、引数を左から順に評価し、最初に NULL でない値を返します。NULL のまま表示・計算すると意図しない結果になる場面で、デフォルト値を設定するために使います。たとえば、担当者が未割り当て（NULL）のタスクに「未割り当て」と表示したり、NULL を 0 として集計に含めたりできます。

```sql
-- COALESCE による NULL 置換
-- タスクの担当者IDを表示し、未割り当ての場合は 0 にする
SELECT
    id,
    title,
    COALESCE(assignee_id, 0) AS assignee_id
FROM tasks;
```

## 10. ORDER BY によるソート

**ファイル:** `sql/1-select/9-order-by.sql`

取得結果を指定したカラムで並び替えます。

`ORDER BY` 句を使うと、結果セットを任意のカラムで昇順（`ASC`、デフォルト）または降順（`DESC`）に並び替えられます。複数のカラムを指定すると、最初のカラムが同値の場合に次のカラムでソートされます。`ORDER BY` を指定しない場合、行の順序は保証されません。

```sql
-- ORDER BY によるソート
-- 従業員を入社日の新しい順に取得する
SELECT id, last_name, first_name, hire_date
FROM employees
ORDER BY hire_date DESC;
```

## 11. LIMIT / OFFSET によるページング

**ファイル:** `sql/1-select/10-limit-offset.sql`

取得件数を制限し、ページネーションを実現します。

`LIMIT` で取得する最大行数を、`OFFSET` で読み飛ばす行数を指定します。2つを組み合わせることで、ページ送りのような動作が実現できます。`OFFSET` は行数が増えるほどパフォーマンスが低下するため、大量データでは別の手法（キーセットページング等）が推奨されます。

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

## 12. DISTINCT による重複排除

**ファイル:** `sql/1-select/11-distinct.sql`

重複する行を除外してユニークな結果だけを取得します。

`DISTINCT` を `SELECT` の直後に置くと、結果セットから重複行が取り除かれます。特定のカラムにどのような値が存在するかを調べたいときに便利です。ただし、内部的にソートやハッシュ処理が発生するため、大量データでは `GROUP BY` の方が効率的な場合もあります。

```sql
-- DISTINCT による重複排除
-- タスクに存在するステータスの一覧を取得する
SELECT DISTINCT status FROM tasks;
```

## 13. 集約関数 (COUNT, SUM, AVG, MAX, MIN)

**ファイル:** `sql/1-select/12-aggregate-functions.sql`

複数行のデータをグループごとに集計します。

集約関数は複数の行を1つの値にまとめます。`COUNT` は行数、`SUM` は合計、`AVG` は平均、`MAX`/`MIN` は最大値・最小値を返します。`GROUP BY` と組み合わせると、指定したカラムの値ごとにグループ化して集計できます。`GROUP BY` を省略すると、テーブル全体が1つのグループとして扱われます。

```sql
-- 集約関数 (COUNT, SUM, AVG, MAX, MIN)
-- 従業員の総数を取得する
SELECT COUNT(*) AS total_employees FROM employees;

-- 部署ごとの従業員数を取得する
SELECT department_id, COUNT(*) AS employee_count
FROM employees
GROUP BY department_id;
```

## 14. HAVING による集約結果の絞り込み

**ファイル:** `sql/1-select/13-having.sql`

集約後の結果に対して条件で絞り込みます。

`HAVING` 句は `GROUP BY` で集約した後の結果に条件を適用します。`WHERE` がグループ化前の各行に対して機能するのに対し、`HAVING` はグループ化後の集約値（`COUNT`、`SUM` など）に対して機能します。そのため、「従業員が10人以上の部署」のような集約結果に基づくフィルタリングには `HAVING` を使います。

```sql
-- HAVING による集約結果の絞り込み
-- 従業員が 10 人以上の部署を取得する
SELECT department_id, COUNT(*) AS employee_count
FROM employees
GROUP BY department_id
HAVING COUNT(*) >= 10;
```

---

[BASIC](README.md) | [次へ: SELECT 応用](2-advanced-select.md) →
