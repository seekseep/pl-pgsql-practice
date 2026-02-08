# カーソル

> ※ 変数・条件分岐・ループを使用。例外処理は使いません

## 0. 基本的なカーソル (OPEN / FETCH / CLOSE)

**ファイル:** `sql/3-cursor/0-basic-cursor.sql`

カーソルの基本操作である `OPEN` → `FETCH` → `CLOSE` の流れを示します。大量データを 1 行ずつ処理する場合に使います。

```sql
-- ============================================================
-- 基本的なカーソル (OPEN → FETCH → CLOSE)
-- ============================================================
-- カーソルを使うと大量データを 1 行ずつ処理できる

DO $$
DECLARE
    cur_employees CURSOR FOR
        SELECT id, last_name, first_name, email
        FROM employees
        WHERE is_active = TRUE
        ORDER BY id;
    v_rec   RECORD;
    v_count INT := 0;
BEGIN
    OPEN cur_employees;

    LOOP
        FETCH cur_employees INTO v_rec;
        EXIT WHEN NOT FOUND;

        v_count := v_count + 1;
        IF v_count <= 5 THEN
            RAISE NOTICE '% % (%)', v_rec.last_name, v_rec.first_name, v_rec.email;
        END IF;
    END LOOP;

    CLOSE cur_employees;
    RAISE NOTICE '合計: % 人', v_count;
END;
$$;
```

### 実行方法

> GUI ツール（pgAdmin, DBeaver 等）では、上記の SQL をクエリエディタに貼り付けて実行できます。

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/3-basic-control/sql/3-cursor/0-basic-cursor.sql
```

## 1. パラメータ付きカーソル

**ファイル:** `sql/3-cursor/1-parameterized.sql`

カーソル宣言時に引数を定義し、`OPEN` 時に値を渡す方法を示します。同じカーソルを異なるパラメータで再利用できます。

```sql
-- ============================================================
-- パラメータ付きカーソル
-- ============================================================
-- カーソル宣言時に引数を定義し、OPEN 時に値を渡す

DO $$
DECLARE
    cur_tasks CURSOR (p_project_id INT, p_status VARCHAR) FOR
        SELECT t.id, t.title, t.priority,
               e.last_name || ' ' || e.first_name AS assignee_name
        FROM tasks t
        LEFT JOIN employees e ON t.assignee_id = e.id
        WHERE t.project_id = p_project_id
          AND t.status = p_status
        ORDER BY t.id;
    v_rec RECORD;
BEGIN
    OPEN cur_tasks(1, 'todo');

    LOOP
        FETCH cur_tasks INTO v_rec;
        EXIT WHEN NOT FOUND;

        RAISE NOTICE '[%] % (担当: %)',
            v_rec.priority, v_rec.title, COALESCE(v_rec.assignee_name, '未割当');
    END LOOP;

    CLOSE cur_tasks;
END;
$$;
```

### 実行方法

> GUI ツール（pgAdmin, DBeaver 等）では、上記の SQL をクエリエディタに貼り付けて実行できます。

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/3-basic-control/sql/3-cursor/1-parameterized.sql
```

## 2. FOR ループによるカーソルの簡略化

**ファイル:** `sql/3-cursor/2-for-cursor.sql`

FOR ループを使うと `OPEN` / `FETCH` / `CLOSE` を自動で行ってくれる簡略記法を示します。カーソルの使い方として最も簡潔です。

```sql
-- ============================================================
-- FOR ループによるカーソルの簡略化
-- ============================================================
-- FOR ループを使うと OPEN / FETCH / CLOSE を自動で行ってくれる

DO $$
DECLARE
    cur_depts CURSOR FOR
        SELECT d.id, d.name, COUNT(e.id) AS emp_count
        FROM departments d
        LEFT JOIN employees e ON d.id = e.department_id
        GROUP BY d.id, d.name
        ORDER BY d.id;
BEGIN
    FOR v_rec IN cur_depts LOOP
        RAISE NOTICE '部署[%]: % (% 人)', v_rec.id, v_rec.name, v_rec.emp_count;
    END LOOP;
    -- CLOSE は自動で呼ばれる
END;
$$;
```

### 実行方法

> GUI ツール（pgAdmin, DBeaver 等）では、上記の SQL をクエリエディタに貼り付けて実行できます。

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/3-basic-control/sql/3-cursor/2-for-cursor.sql
```

## 3. カーソルを使ったバッチ処理

**ファイル:** `sql/3-cursor/3-batch-processing.sql`

大量データを N 件ずつ区切って処理するバッチ処理パターンを示します。ジョブログを 10 件ずつバッチに分けて処理します。

```sql
-- ============================================================
-- カーソルを使ったバッチ処理
-- ============================================================
-- 大量データを N 件ずつ区切って処理する

DO $$
DECLARE
    cur_logs CURSOR FOR
        SELECT jl.id, j.name AS job_name, jl.status, jl.started_at
        FROM job_logs jl
        INNER JOIN jobs j ON jl.job_id = j.id
        ORDER BY jl.id;
    v_rec       RECORD;
    v_batch     INT := 0;
    v_batch_cnt INT := 0;
BEGIN
    OPEN cur_logs;

    LOOP
        FETCH cur_logs INTO v_rec;
        EXIT WHEN NOT FOUND;

        v_batch_cnt := v_batch_cnt + 1;

        IF v_batch_cnt = 1 THEN
            v_batch := v_batch + 1;
            RAISE NOTICE '--- バッチ % ---', v_batch;
        END IF;

        IF v_batch <= 3 THEN
            RAISE NOTICE '  [%] % : %', v_rec.status, v_rec.job_name, v_rec.started_at;
        END IF;

        IF v_batch_cnt >= 10 THEN
            v_batch_cnt := 0;
        END IF;
    END LOOP;

    CLOSE cur_logs;
    RAISE NOTICE '全バッチ完了 (計 % バッチ)', v_batch;
END;
$$;
```

### 実行方法

> GUI ツール（pgAdmin, DBeaver 等）では、上記の SQL をクエリエディタに貼り付けて実行できます。

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/3-basic-control/sql/3-cursor/3-batch-processing.sql
```

## 4. UPDATE WHERE CURRENT OF

**ファイル:** `sql/3-cursor/4-update-current-of.sql`

カーソルが指している行を `WHERE CURRENT OF` で直接更新する方法を示します。`FOR UPDATE` 付きでカーソルを宣言し、低優先度のタスクを中優先度に変更します。

```sql
-- ============================================================
-- UPDATE WHERE CURRENT OF
-- ============================================================
-- カーソルが指している行を直接更新する

DO $$
DECLARE
    cur_tasks CURSOR FOR
        SELECT id, title, priority
        FROM tasks
        WHERE status = 'todo' AND priority = 'low'
        FOR UPDATE;
    v_rec   RECORD;
    v_count INT := 0;
BEGIN
    OPEN cur_tasks;

    LOOP
        FETCH cur_tasks INTO v_rec;
        EXIT WHEN NOT FOUND;

        UPDATE tasks
        SET priority = 'medium', updated_at = CURRENT_TIMESTAMP
        WHERE CURRENT OF cur_tasks;

        v_count := v_count + 1;
    END LOOP;

    CLOSE cur_tasks;
    RAISE NOTICE '% 件のタスクの優先度を medium に変更しました', v_count;
END;
$$;
```

### 実行方法

> GUI ツール（pgAdmin, DBeaver 等）では、上記の SQL をクエリエディタに貼り付けて実行できます。

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/3-basic-control/sql/3-cursor/4-update-current-of.sql
```

## 5. SCROLL カーソル

**ファイル:** `sql/3-cursor/5-scroll-cursor.sql`

`SCROLL` を付けて前後に移動できるカーソルを作成する方法を示します。`FETCH NEXT`、`FETCH PRIOR`、`FETCH LAST`、`FETCH FIRST` で自由な方向に移動できます。

```sql
-- ============================================================
-- SCROLL カーソル
-- ============================================================
-- SCROLL を付けると前後に移動できるカーソルになる

DO $$
DECLARE
    cur SCROLL CURSOR FOR
        SELECT id, name FROM departments ORDER BY id;
    v_rec RECORD;
BEGIN
    OPEN cur;

    RAISE NOTICE '--- 順方向 ---';
    FOR i IN 1..3 LOOP
        FETCH NEXT FROM cur INTO v_rec;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE '→ % : %', v_rec.id, v_rec.name;
    END LOOP;

    RAISE NOTICE '--- 逆方向 ---';
    FOR i IN 1..2 LOOP
        FETCH PRIOR FROM cur INTO v_rec;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE '← % : %', v_rec.id, v_rec.name;
    END LOOP;

    FETCH LAST FROM cur INTO v_rec;
    RAISE NOTICE '最後: % : %', v_rec.id, v_rec.name;

    FETCH FIRST FROM cur INTO v_rec;
    RAISE NOTICE '最初: % : %', v_rec.id, v_rec.name;

    CLOSE cur;
END;
$$;
```

### 実行方法

> GUI ツール（pgAdmin, DBeaver 等）では、上記の SQL をクエリエディタに貼り付けて実行できます。

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/3-basic-control/sql/3-cursor/5-scroll-cursor.sql
```

---

← [前へ: ループ](2-loop.md) | [BASIC_CONTROL](README.md) | [次へ: 例外処理](4-exception.md) →
