# 条件分岐

> ※ 変数のみ使用。ループ・カーソル・例外処理は使いません

## 0. IF ... THEN ... END IF

**ファイル:** `sql/1-condition/0-if-then.sql`

最も基本的な条件分岐です。条件が `TRUE` のときだけ処理を実行します。

```sql
-- ============================================================
-- IF ... THEN ... END IF
-- ============================================================
-- 条件が TRUE のときだけ処理を実行する

DO $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count FROM employees WHERE is_active = TRUE;

    IF v_count > 50 THEN
        RAISE NOTICE 'アクティブ従業員は % 人です (50人超)', v_count;
    END IF;
END;
$$;
```

### 実行方法

> GUI ツール（pgAdmin, DBeaver 等）では、上記の SQL をクエリエディタに貼り付けて実行できます。

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/3-basic-control/sql/1-condition/0-if-then.sql
```

## 1. IF ... THEN ... ELSE

**ファイル:** `sql/1-condition/1-if-else.sql`

条件が `TRUE` / `FALSE` の二択で分岐する方法を示します。どちらの場合でも必ず何らかの処理を行いたいときに使います。

```sql
-- ============================================================
-- IF ... THEN ... ELSE
-- ============================================================
-- 条件が TRUE / FALSE の二択で分岐する

DO $$
DECLARE
    v_employee employees%ROWTYPE;
BEGIN
    SELECT * INTO v_employee FROM employees WHERE id = 1;

    IF v_employee.is_active THEN
        RAISE NOTICE '% % は在籍中です', v_employee.last_name, v_employee.first_name;
    ELSE
        RAISE NOTICE '% % は退職済みです', v_employee.last_name, v_employee.first_name;
    END IF;
END;
$$;
```

### 実行方法

> GUI ツール（pgAdmin, DBeaver 等）では、上記の SQL をクエリエディタに貼り付けて実行できます。

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/3-basic-control/sql/1-condition/1-if-else.sql
```

## 2. IF ... ELSIF ... ELSE

**ファイル:** `sql/1-condition/2-if-elsif.sql`

3 つ以上の条件で分岐する方法を示します。`ELSIF` を使って複数の条件を順番に評価し、最初に `TRUE` になった分岐が実行されます。

```sql
-- ============================================================
-- IF ... ELSIF ... ELSE
-- ============================================================
-- 3 つ以上の条件で分岐する

DO $$
DECLARE
    v_task_count INT;
    v_project    projects%ROWTYPE;
BEGIN
    SELECT * INTO v_project FROM projects WHERE id = 1;

    SELECT COUNT(*) INTO v_task_count
    FROM tasks WHERE project_id = v_project.id;

    IF v_task_count = 0 THEN
        RAISE NOTICE 'プロジェクト「%」にはタスクがありません', v_project.name;
    ELSIF v_task_count <= 10 THEN
        RAISE NOTICE 'プロジェクト「%」のタスク数は少なめです (% 件)', v_project.name, v_task_count;
    ELSIF v_task_count <= 20 THEN
        RAISE NOTICE 'プロジェクト「%」のタスク数は普通です (% 件)', v_project.name, v_task_count;
    ELSE
        RAISE NOTICE 'プロジェクト「%」のタスク数は多いです (% 件)', v_project.name, v_task_count;
    END IF;
END;
$$;
```

### 実行方法

> GUI ツール（pgAdmin, DBeaver 等）では、上記の SQL をクエリエディタに貼り付けて実行できます。

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/3-basic-control/sql/1-condition/2-if-elsif.sql
```

## 3. 複合条件 (AND / OR)

**ファイル:** `sql/1-condition/3-and-or.sql`

`AND`（両方 TRUE で成立）と `OR`（どちらかが TRUE で成立）を使った複合条件の書き方を示します。`NOT` による否定も組み合わせています。

```sql
-- ============================================================
-- 複合条件 (AND / OR)
-- ============================================================
-- AND: 両方 TRUE で成立、OR: どちらかが TRUE で成立

DO $$
DECLARE
    v_emp employees%ROWTYPE;
BEGIN
    SELECT * INTO v_emp FROM employees WHERE id = 1;

    IF v_emp.is_active AND v_emp.hire_date < '2025-07-01' THEN
        RAISE NOTICE '% % はベテラン社員です', v_emp.last_name, v_emp.first_name;
    END IF;

    IF NOT v_emp.is_active OR v_emp.hire_date >= '2026-01-01' THEN
        RAISE NOTICE '% % は退職済みまたは新入社員です', v_emp.last_name, v_emp.first_name;
    ELSE
        RAISE NOTICE '% % は在籍中の既存社員です', v_emp.last_name, v_emp.first_name;
    END IF;
END;
$$;
```

### 実行方法

> GUI ツール（pgAdmin, DBeaver 等）では、上記の SQL をクエリエディタに貼り付けて実行できます。

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/3-basic-control/sql/1-condition/3-and-or.sql
```

## 4. CASE 文 (単純 CASE)

**ファイル:** `sql/1-condition/4-case-simple.sql`

1 つの値を複数の候補と比較して分岐する単純 CASE 文を示します。プロジェクトのステータスを日本語ラベルに変換する例です。

```sql
-- ============================================================
-- CASE 文 (単純 CASE)
-- ============================================================
-- 1 つの値を複数の候補と比較して分岐する

DO $$
DECLARE
    v_project projects%ROWTYPE;
    v_label   VARCHAR(20);
BEGIN
    SELECT * INTO v_project FROM projects WHERE id = 1;

    CASE v_project.status
        WHEN 'planning'  THEN v_label := '計画中';
        WHEN 'active'    THEN v_label := '進行中';
        WHEN 'completed' THEN v_label := '完了';
        WHEN 'archived'  THEN v_label := 'アーカイブ済';
        ELSE v_label := '不明';
    END CASE;

    RAISE NOTICE 'プロジェクト「%」のステータス: %', v_project.name, v_label;
END;
$$;
```

### 実行方法

> GUI ツール（pgAdmin, DBeaver 等）では、上記の SQL をクエリエディタに貼り付けて実行できます。

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/3-basic-control/sql/1-condition/4-case-simple.sql
```

## 5. CASE 文 (検索 CASE)

**ファイル:** `sql/1-condition/5-case-searched.sql`

`WHEN` に条件式を書いて分岐する検索 CASE 文を示します。`IF...ELSIF` の代替として使え、タスクの完了率に応じてメッセージを出し分けます。

```sql
-- ============================================================
-- CASE 文 (検索 CASE)
-- ============================================================
-- WHEN に条件式を書いて分岐する (IF...ELSIF の代替)

DO $$
DECLARE
    v_done_rate  NUMERIC;
    v_project_id INT := 1;
    v_total      INT;
    v_done       INT;
BEGIN
    SELECT COUNT(*), COUNT(CASE WHEN status = 'done' THEN 1 END)
    INTO v_total, v_done
    FROM tasks
    WHERE project_id = v_project_id;

    IF v_total > 0 THEN
        v_done_rate := (v_done::NUMERIC / v_total) * 100;
    ELSE
        v_done_rate := 0;
    END IF;

    CASE
        WHEN v_done_rate = 100 THEN
            RAISE NOTICE '全タスク完了! (100%%)';
        WHEN v_done_rate >= 75 THEN
            RAISE NOTICE 'ほぼ完了 (%.1f%%)', v_done_rate;
        WHEN v_done_rate >= 50 THEN
            RAISE NOTICE '半分以上完了 (%.1f%%)', v_done_rate;
        WHEN v_done_rate >= 25 THEN
            RAISE NOTICE '進行中 (%.1f%%)', v_done_rate;
        ELSE
            RAISE NOTICE 'まだ序盤 (%.1f%%)', v_done_rate;
    END CASE;
END;
$$;
```

### 実行方法

> GUI ツール（pgAdmin, DBeaver 等）では、上記の SQL をクエリエディタに貼り付けて実行できます。

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/3-basic-control/sql/1-condition/5-case-searched.sql
```

## 6. NULL チェック

**ファイル:** `sql/1-condition/6-null-check.sql`

`IS NULL` / `IS NOT NULL` で NULL を判定する方法を示します。担当者未割り当てのタスクや期限切れの判定を行います。

```sql
-- ============================================================
-- NULL チェック
-- ============================================================
-- IS NULL / IS NOT NULL で NULL を判定する

DO $$
DECLARE
    v_task tasks%ROWTYPE;
BEGIN
    SELECT * INTO v_task FROM tasks WHERE id = 1;

    IF v_task.assignee_id IS NULL THEN
        RAISE NOTICE 'タスク「%」は担当者未割り当てです', v_task.title;
    ELSE
        RAISE NOTICE 'タスク「%」の担当者ID: %', v_task.title, v_task.assignee_id;
    END IF;

    IF v_task.due_date IS NOT NULL AND v_task.due_date < CURRENT_DATE THEN
        RAISE NOTICE '※ このタスクは期限切れです (期限: %)', v_task.due_date;
    END IF;
END;
$$;
```

### 実行方法

> GUI ツール（pgAdmin, DBeaver 等）では、上記の SQL をクエリエディタに貼り付けて実行できます。

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/3-basic-control/sql/1-condition/6-null-check.sql
```

## 7. ネストした IF

**ファイル:** `sql/1-condition/7-nested-if.sql`

IF の中にさらに IF を書いて、段階的に判定する方法を示します。在籍・退職の判定の後、在籍中の場合はさらに入社歴で分岐します。

```sql
-- ============================================================
-- ネストした IF
-- ============================================================
-- IF の中にさらに IF を書いて、段階的に判定する
-- ※ LOOP は次の 2-loop で学ぶため、ここでは 1 レコードで示す

DO $$
DECLARE
    v_emp  employees%ROWTYPE;
    v_dept departments%ROWTYPE;
BEGIN
    SELECT * INTO v_emp FROM employees WHERE id = 1;
    SELECT * INTO v_dept FROM departments WHERE id = v_emp.department_id;

    IF v_emp.is_active THEN
        IF v_emp.hire_date < CURRENT_DATE - INTERVAL '1 year' THEN
            RAISE NOTICE '[在籍/経験1年超] % % (%)', v_emp.last_name, v_emp.first_name, v_dept.name;
        ELSE
            RAISE NOTICE '[在籍/新人] % % (%)', v_emp.last_name, v_emp.first_name, v_dept.name;
        END IF;
    ELSE
        RAISE NOTICE '[退職済] % %', v_emp.last_name, v_emp.first_name;
    END IF;
END;
$$;
```

### 実行方法

> GUI ツール（pgAdmin, DBeaver 等）では、上記の SQL をクエリエディタに貼り付けて実行できます。

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/3-basic-control/sql/1-condition/7-nested-if.sql
```

---

← [前へ: 変数](0-variables.md) | [BASIC_CONTROL](README.md) | [次へ: ループ](2-loop.md) →
