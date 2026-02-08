# CTE (WITH 句) とウィンドウ関数

## 1. 基本的な CTE (WITH 句)

**ファイル:** `sql/5-cte-window/1-basic-cte.sql`

CTE (Common Table Expression) を使って、サブクエリに名前を付けて可読性を向上させます。部署ごとの従業員数を集計する例です。

```sql
-- ============================================================
-- 基本的な CTE (WITH 句)
-- ============================================================

DO $$
DECLARE
    v_rec RECORD;
BEGIN
    FOR v_rec IN
        WITH dept_stats AS (
            SELECT
                d.id,
                d.name,
                COUNT(e.id) AS emp_count
            FROM departments d
            LEFT JOIN employees e ON d.id = e.department_id
            GROUP BY d.id, d.name
        )
        SELECT * FROM dept_stats ORDER BY emp_count DESC
    LOOP
        RAISE NOTICE '部署: % (% 人)', v_rec.name, v_rec.emp_count;
    END LOOP;
END;
$$;
```

## 2. 複数 CTE を組み合わせる

**ファイル:** `sql/5-cte-window/2-multiple-cte.sql`

複数の CTE をカンマ区切りで定義し、それぞれを結合して使います。部署ごとの従業員数と未完了タスク数を同時に集計する例です。

```sql
-- ============================================================
-- 複数 CTE を組み合わせる
-- ============================================================

DO $$
DECLARE
    v_rec RECORD;
BEGIN
    FOR v_rec IN
        WITH dept_emp AS (
            SELECT department_id, COUNT(*) AS emp_count
            FROM employees
            WHERE is_active = TRUE
            GROUP BY department_id
        ),
        dept_tasks AS (
            SELECT e.department_id, COUNT(t.id) AS task_count
            FROM tasks t
            INNER JOIN employees e ON t.assignee_id = e.id
            WHERE t.status != 'done'
            GROUP BY e.department_id
        )
        SELECT
            d.name,
            COALESCE(de.emp_count, 0)  AS emp_count,
            COALESCE(dt.task_count, 0) AS task_count
        FROM departments d
        LEFT JOIN dept_emp   de ON d.id = de.department_id
        LEFT JOIN dept_tasks dt ON d.id = dt.department_id
        ORDER BY d.id
    LOOP
        RAISE NOTICE '%: 従業員 % 人, 未完了タスク % 件',
            v_rec.name, v_rec.emp_count, v_rec.task_count;
    END LOOP;
END;
$$;
```

## 3. 再帰 CTE (WITH RECURSIVE)

**ファイル:** `sql/5-cte-window/3-recursive-cte.sql`

`WITH RECURSIVE` を使って再帰的なデータ生成を行います。月初の日付列を生成し、各月のタスク件数を集計する例です。

```sql
-- ============================================================
-- 再帰 CTE (WITH RECURSIVE)
-- ============================================================

-- 月初の日付列を生成する例
DO $$
DECLARE
    v_rec RECORD;
BEGIN
    FOR v_rec IN
        WITH RECURSIVE month_series AS (
            SELECT DATE '2025-01-01' AS month_start
            UNION ALL
            SELECT (month_start + INTERVAL '1 month')::DATE
            FROM month_series
            WHERE month_start < DATE '2025-06-01'
        )
        SELECT
            ms.month_start,
            COUNT(t.id) AS task_count
        FROM month_series ms
        LEFT JOIN tasks t
            ON t.created_at >= ms.month_start
           AND t.created_at <  (ms.month_start + INTERVAL '1 month')
        GROUP BY ms.month_start
        ORDER BY ms.month_start
    LOOP
        RAISE NOTICE '%: タスク % 件',
            TO_CHAR(v_rec.month_start, 'YYYY-MM'), v_rec.task_count;
    END LOOP;
END;
$$;
```

## 4. ROW_NUMBER() ウィンドウ関数

**ファイル:** `sql/5-cte-window/4-row-number.sql`

`ROW_NUMBER()` ウィンドウ関数を使って、パーティションごとに連番を振ります。部署ごとに入社順の番号を付与する例です。

```sql
-- ============================================================
-- ROW_NUMBER() ウィンドウ関数
-- ============================================================

DO $$
DECLARE
    v_rec RECORD;
BEGIN
    FOR v_rec IN
        SELECT
            ROW_NUMBER() OVER (
                PARTITION BY department_id
                ORDER BY hire_date
            ) AS row_num,
            last_name || ' ' || first_name AS full_name,
            department_id,
            hire_date
        FROM employees
        WHERE is_active = TRUE
        ORDER BY department_id, row_num
    LOOP
        IF v_rec.row_num = 1 THEN
            RAISE NOTICE '--- 部署ID: % ---', v_rec.department_id;
        END IF;
        RAISE NOTICE '  #%: % (入社: %)',
            v_rec.row_num, v_rec.full_name, v_rec.hire_date;
    END LOOP;
END;
$$;
```

## 5. RANK / DENSE_RANK ウィンドウ関数

**ファイル:** `sql/5-cte-window/5-rank.sql`

`RANK()` と `DENSE_RANK()` の違いを示します。同順位がある場合に `RANK` は順位を飛ばし、`DENSE_RANK` は連続した順位を付けます。

```sql
-- ============================================================
-- RANK / DENSE_RANK ウィンドウ関数
-- ============================================================

DO $$
DECLARE
    v_rec RECORD;
BEGIN
    RAISE NOTICE '=== 部署別タスク数ランキング ===';
    FOR v_rec IN
        WITH task_counts AS (
            SELECT
                e.department_id,
                d.name AS dept_name,
                e.id AS employee_id,
                e.last_name || ' ' || e.first_name AS full_name,
                COUNT(t.id) AS task_count
            FROM employees e
            INNER JOIN departments d ON e.department_id = d.id
            LEFT JOIN tasks t ON e.id = t.assignee_id
            WHERE e.is_active = TRUE
            GROUP BY e.department_id, d.name, e.id, e.last_name, e.first_name
        )
        SELECT
            dept_name,
            full_name,
            task_count,
            RANK() OVER (
                PARTITION BY department_id ORDER BY task_count DESC
            ) AS rank_num,
            DENSE_RANK() OVER (
                PARTITION BY department_id ORDER BY task_count DESC
            ) AS dense_rank_num
        FROM task_counts
        ORDER BY dept_name, rank_num
    LOOP
        RAISE NOTICE '% | % | タスク: % | RANK: % | DENSE_RANK: %',
            v_rec.dept_name, v_rec.full_name,
            v_rec.task_count, v_rec.rank_num, v_rec.dense_rank_num;
    END LOOP;
END;
$$;
```

## 6. LAG / LEAD ウィンドウ関数

**ファイル:** `sql/5-cte-window/6-lag-lead.sql`

`LAG()` で前の行、`LEAD()` で次の行の値を参照します。プロジェクトの開始日を前後のプロジェクトと比較する例です。

```sql
-- ============================================================
-- LAG / LEAD ウィンドウ関数
-- ============================================================

DO $$
DECLARE
    v_rec RECORD;
BEGIN
    RAISE NOTICE '=== プロジェクト開始日の前後比較 ===';
    FOR v_rec IN
        SELECT
            name,
            start_date,
            LAG(start_date)  OVER (ORDER BY start_date) AS prev_start,
            LEAD(start_date) OVER (ORDER BY start_date) AS next_start,
            start_date - LAG(start_date) OVER (ORDER BY start_date) AS days_since_prev
        FROM projects
        WHERE start_date IS NOT NULL
        ORDER BY start_date
    LOOP
        RAISE NOTICE '% (開始: %) | 前: % | 次: % | 前との差: % 日',
            v_rec.name, v_rec.start_date,
            COALESCE(v_rec.prev_start::TEXT, '-'),
            COALESCE(v_rec.next_start::TEXT, '-'),
            COALESCE(v_rec.days_since_prev::TEXT, '-');
    END LOOP;
END;
$$;
```

## 7. SUM / AVG ウィンドウ関数 (累計・移動平均)

**ファイル:** `sql/5-cte-window/7-sum-avg-window.sql`

ウィンドウフレームを指定した `SUM` と `AVG` を使い、累計値と移動平均を計算します。部署別の月ごとの入社人数の累計と3ヶ月移動平均を求める例です。

```sql
-- ============================================================
-- SUM / AVG ウィンドウ関数 (累計・移動平均)
-- ============================================================

DO $$
DECLARE
    v_rec RECORD;
BEGIN
    RAISE NOTICE '=== 部署別従業員の累計と移動平均 ===';
    FOR v_rec IN
        WITH dept_hire AS (
            SELECT
                d.name AS dept_name,
                DATE_TRUNC('month', e.hire_date)::DATE AS hire_month,
                COUNT(*) AS hire_count
            FROM employees e
            INNER JOIN departments d ON e.department_id = d.id
            GROUP BY d.name, DATE_TRUNC('month', e.hire_date)
        )
        SELECT
            dept_name,
            hire_month,
            hire_count,
            SUM(hire_count) OVER (
                PARTITION BY dept_name
                ORDER BY hire_month
                ROWS UNBOUNDED PRECEDING
            ) AS cumulative_total,
            ROUND(AVG(hire_count) OVER (
                PARTITION BY dept_name
                ORDER BY hire_month
                ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
            ), 1) AS moving_avg_3
        FROM dept_hire
        ORDER BY dept_name, hire_month
    LOOP
        RAISE NOTICE '% | % | 入社: % | 累計: % | 移動平均: %',
            v_rec.dept_name, v_rec.hire_month,
            v_rec.hire_count, v_rec.cumulative_total, v_rec.moving_avg_3;
    END LOOP;
END;
$$;
```

---

← [前へ: 配列 (ARRAY) と JSON](4-array-json.md) | [ADVANCED_CONTROL](README.md) | [次へ: 関数 (FUNCTION) とトリガー (TRIGGER)](6-function-trigger.md) →
