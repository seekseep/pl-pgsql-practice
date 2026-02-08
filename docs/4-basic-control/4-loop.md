# ループ

> ※ 変数と条件分岐を使用。カーソル・例外処理は使いません

## 1. 基本 LOOP (無限ループ + EXIT)

**ファイル:** `sql/3-loop/1-loop-exit.sql`

`LOOP` は `EXIT` で明示的に抜けるまで繰り返す無限ループです。`EXIT WHEN` でカウンターが上限を超えたらループを終了します。

```sql
-- ============================================================
-- 基本 LOOP (無限ループ + EXIT)
-- ============================================================
-- LOOP は EXIT で明示的に抜けるまで繰り返す

DO $$
DECLARE
    v_counter INT := 0;
BEGIN
    LOOP
        v_counter := v_counter + 1;
        EXIT WHEN v_counter > 5;
        RAISE NOTICE 'カウンター: %', v_counter;
    END LOOP;
    RAISE NOTICE 'ループ終了 (最終値: %)', v_counter;
END;
$$;
```

**Java 風疑似コード:**

```java
int counter = 0;
while (true) {
    counter++;
    if (counter > 5) break;
    System.out.println("カウンター: " + counter);
}
System.out.println("ループ終了 (最終値: " + counter + ")");
```

## 2. WHILE ループ

**ファイル:** `sql/3-loop/2-while.sql`

条件が `TRUE` の間だけ繰り返す `WHILE` ループを示します。部署 ID を 1 ずつ増やしながら全部署を走査します。

```sql
-- ============================================================
-- WHILE ループ
-- ============================================================
-- 条件が TRUE の間だけ繰り返す

DO $$
DECLARE
    v_dept_id   INT := 1;
    v_dept_name VARCHAR(100);
    v_max_dept  INT;
BEGIN
    SELECT MAX(id) INTO v_max_dept FROM departments;

    WHILE v_dept_id <= v_max_dept LOOP
        SELECT name INTO v_dept_name FROM departments WHERE id = v_dept_id;

        IF FOUND THEN
            RAISE NOTICE '部署 %: %', v_dept_id, v_dept_name;
        END IF;

        v_dept_id := v_dept_id + 1;
    END LOOP;
END;
$$;
```

**Java 風疑似コード:**

```java
int deptId = 1;
int maxDept = db.query("SELECT MAX(id) FROM departments");

while (deptId <= maxDept) {
    String deptName = db.queryOrNull("SELECT name FROM departments WHERE id = ?", deptId);

    if (deptName != null) {
        System.out.println("部署 " + deptId + ": " + deptName);
    }

    deptId++;
}
```

## 3. FOR ループ (整数範囲)

**ファイル:** `sql/3-loop/3-for-integer.sql`

`FOR i IN 開始..終了` で整数を順に回す FOR ループを示します。`REVERSE` による降順ループや `BY` によるステップ指定も紹介しています。

```sql
-- ============================================================
-- FOR ループ (整数範囲)
-- ============================================================
-- FOR i IN 開始..終了 で整数を順に回す

DO $$
BEGIN
    -- 1 から 5 まで
    FOR i IN 1..5 LOOP
        RAISE NOTICE 'i = %', i;
    END LOOP;

    -- REVERSE で降順
    RAISE NOTICE '--- 降順 ---';
    FOR i IN REVERSE 5..1 LOOP
        RAISE NOTICE 'i = %', i;
    END LOOP;

    -- BY でステップ指定
    RAISE NOTICE '--- 2刻み ---';
    FOR i IN 1..10 BY 2 LOOP
        RAISE NOTICE 'i = %', i;
    END LOOP;
END;
$$;
```

**Java 風疑似コード:**

```java
// 1 から 5 まで
for (int i = 1; i <= 5; i++) {
    System.out.println("i = " + i);
}

// 降順
System.out.println("--- 降順 ---");
for (int i = 5; i >= 1; i--) {
    System.out.println("i = " + i);
}

// 2刻み
System.out.println("--- 2刻み ---");
for (int i = 1; i <= 10; i += 2) {
    System.out.println("i = " + i);
}
```

## 4. FOR ループ (クエリ結果)

**ファイル:** `sql/3-loop/4-for-query.sql`

`SELECT` の結果を 1 行ずつ `RECORD` に格納してループで処理する方法を示します。部署ごとの従業員数を一覧表示します。

```sql
-- ============================================================
-- FOR ループ (クエリ結果)
-- ============================================================
-- SELECT の結果を 1 行ずつ RECORD に格納して処理する

DO $$
DECLARE
    v_rec RECORD;
BEGIN
    FOR v_rec IN
        SELECT d.name AS dept_name, COUNT(e.id) AS emp_count
        FROM departments d
        LEFT JOIN employees e ON d.id = e.department_id
        GROUP BY d.id, d.name
        ORDER BY d.id
    LOOP
        RAISE NOTICE '% : % 人', v_rec.dept_name, v_rec.emp_count;
    END LOOP;
END;
$$;
```

**Java 風疑似コード:**

```java
List<Row> rows = db.query(
    "SELECT d.name AS dept_name, COUNT(e.id) AS emp_count " +
    "FROM departments d LEFT JOIN employees e ON d.id = e.department_id " +
    "GROUP BY d.id, d.name ORDER BY d.id"
);

for (Row rec : rows) {
    System.out.println(rec.deptName + " : " + rec.empCount + " 人");
}
```

## 5. FOR ループ (動的 SQL)

**ファイル:** `sql/3-loop/5-for-execute.sql`

`EXECUTE` で文字列として組み立てた SQL の結果をループで処理する方法を示します。`USING` でパラメータを安全に渡します。

```sql
-- ============================================================
-- FOR ループ (動的 SQL)
-- ============================================================
-- EXECUTE で文字列として組み立てた SQL の結果をループする

DO $$
DECLARE
    v_rec   RECORD;
    v_query TEXT;
BEGIN
    v_query := 'SELECT id, name, status FROM projects WHERE status = $1 ORDER BY id';

    FOR v_rec IN EXECUTE v_query USING 'active'
    LOOP
        RAISE NOTICE 'プロジェクト[%]: % (%)', v_rec.id, v_rec.name, v_rec.status;
    END LOOP;
END;
$$;
```

**Java 風疑似コード:**

```java
String query = "SELECT id, name, status FROM projects WHERE status = ? ORDER BY id";

List<Row> rows = db.query(query, "active");  // パラメータを安全にバインド

for (Row rec : rows) {
    System.out.println("プロジェクト[" + rec.id + "]: " + rec.name + " (" + rec.status + ")");
}
```

## 6. CONTINUE (スキップ)

**ファイル:** `sql/3-loop/6-continue.sql`

`CONTINUE` で現在の反復を飛ばして次へ進む方法を示します。`CONTINUE WHEN` を使って退職済みの従業員をスキップし、在籍中の従業員のみ表示します。

```sql
-- ============================================================
-- CONTINUE (スキップ)
-- ============================================================
-- CONTINUE で現在の反復を飛ばして次へ進む

DO $$
DECLARE
    v_rec RECORD;
BEGIN
    FOR v_rec IN
        SELECT id, last_name, first_name, is_active
        FROM employees
        ORDER BY id
        LIMIT 20
    LOOP
        -- 退職済みの従業員はスキップ
        CONTINUE WHEN NOT v_rec.is_active;

        RAISE NOTICE '[在籍] ID=%, % %', v_rec.id, v_rec.last_name, v_rec.first_name;
    END LOOP;
END;
$$;
```

**Java 風疑似コード:**

```java
List<Row> rows = db.query(
    "SELECT id, last_name, first_name, is_active FROM employees ORDER BY id LIMIT 20"
);

for (Row rec : rows) {
    // 退職済みの従業員はスキップ
    if (!rec.isActive) continue;

    System.out.println("[在籍] ID=" + rec.id + ", " + rec.lastName + " " + rec.firstName);
}
```

## 7. EXIT (条件付き脱出)

**ファイル:** `sql/3-loop/7-exit-condition.sql`

特定の条件でループを途中終了する方法を示します。タスクをループで走査し、最初の緊急タスクを見つけたら `EXIT` でループを抜けます。

```sql
-- ============================================================
-- EXIT (条件付き脱出)
-- ============================================================
-- 特定の条件でループを途中終了する

DO $$
DECLARE
    v_rec RECORD;
BEGIN
    FOR v_rec IN
        SELECT t.id, t.title, t.priority, p.name AS project_name
        FROM tasks t
        INNER JOIN projects p ON t.project_id = p.id
        ORDER BY t.id
    LOOP
        IF v_rec.priority = 'urgent' THEN
            RAISE NOTICE '緊急タスク発見! [%] % (プロジェクト: %)',
                v_rec.id, v_rec.title, v_rec.project_name;
            EXIT;
        END IF;
    END LOOP;
END;
$$;
```

**Java 風疑似コード:**

```java
List<Row> rows = db.query(
    "SELECT t.id, t.title, t.priority, p.name AS project_name " +
    "FROM tasks t INNER JOIN projects p ON t.project_id = p.id ORDER BY t.id"
);

for (Row rec : rows) {
    if ("urgent".equals(rec.priority)) {
        System.out.println("緊急タスク発見! [" + rec.id + "] " + rec.title +
            " (プロジェクト: " + rec.projectName + ")");
        break;
    }
}
```

## 8. ネストしたループ

**ファイル:** `sql/3-loop/8-nested-loop.sql`

ループの中にループを入れて、組み合わせを処理する方法を示します。プロジェクトごとにタスクを一覧表示するネスト構造です。

```sql
-- ============================================================
-- ネストしたループ
-- ============================================================
-- ループの中にループを入れて、組み合わせを処理する

DO $$
DECLARE
    v_project RECORD;
    v_task    RECORD;
BEGIN
    FOR v_project IN
        SELECT id, name FROM projects WHERE status = 'active' ORDER BY id LIMIT 3
    LOOP
        RAISE NOTICE '=== プロジェクト: % ===', v_project.name;

        FOR v_task IN
            SELECT id, title, status, priority
            FROM tasks
            WHERE project_id = v_project.id
            ORDER BY id
            LIMIT 5
        LOOP
            RAISE NOTICE '  [%/%] %', v_task.status, v_task.priority, v_task.title;
        END LOOP;
    END LOOP;
END;
$$;
```

**Java 風疑似コード:**

```java
List<Row> projects = db.query(
    "SELECT id, name FROM projects WHERE status = 'active' ORDER BY id LIMIT 3"
);

for (Row project : projects) {
    System.out.println("=== プロジェクト: " + project.name + " ===");

    List<Row> tasks = db.query(
        "SELECT id, title, status, priority FROM tasks WHERE project_id = ? ORDER BY id LIMIT 5",
        project.id
    );

    for (Row task : tasks) {
        System.out.println("  [" + task.status + "/" + task.priority + "] " + task.title);
    }
}
```

## 9. ラベル付きループ

**ファイル:** `sql/3-loop/9-labeled-loop.sql`

`<<label>>` でループに名前を付け、外側のループを `CONTINUE` / `EXIT` できるようにする方法を示します。部署内のメンバー一覧で、3 人を超えたら外側の部署ループの次の反復へスキップします。

```sql
-- ============================================================
-- ラベル付きループ
-- ============================================================
-- <<label>> でループに名前を付け、外側のループを CONTINUE / EXIT できる

DO $$
DECLARE
    v_dept RECORD;
    v_emp  RECORD;
    v_cnt  INT;
BEGIN
    <<dept_loop>>
    FOR v_dept IN SELECT id, name FROM departments ORDER BY id LOOP
        v_cnt := 0;

        <<emp_loop>>
        FOR v_emp IN
            SELECT id, last_name, first_name
            FROM employees
            WHERE department_id = v_dept.id
            ORDER BY id
        LOOP
            v_cnt := v_cnt + 1;

            IF v_cnt > 3 THEN
                RAISE NOTICE '  ... (他にもメンバーがいます)';
                CONTINUE dept_loop;  -- 外側のループの次の反復へ
            END IF;

            RAISE NOTICE '[%] % %', v_dept.name, v_emp.last_name, v_emp.first_name;
        END LOOP emp_loop;
    END LOOP dept_loop;
END;
$$;
```

**Java 風疑似コード:**

```java
List<Row> depts = db.query("SELECT id, name FROM departments ORDER BY id");

deptLoop:                                          // ラベル
for (Row dept : depts) {
    int cnt = 0;

    List<Row> emps = db.query(
        "SELECT id, last_name, first_name FROM employees WHERE department_id = ? ORDER BY id",
        dept.id
    );

    for (Row emp : emps) {
        cnt++;

        if (cnt > 3) {
            System.out.println("  ... (他にもメンバーがいます)");
            continue deptLoop;                     // 外側のループの次の反復へ
        }

        System.out.println("[" + dept.name + "] " + emp.lastName + " " + emp.firstName);
    }
}
```

---

← [前へ: 条件分岐](3-condition.md) | [BASIC_CONTROL](README.md) | [次へ: カーソル](5-cursor.md) →
