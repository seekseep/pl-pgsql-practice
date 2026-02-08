# RETURNING INTO

## 1. INSERT ... RETURNING INTO

**ファイル:** `sql/2-returning-into/1-insert-returning.sql`

`INSERT` 文に `RETURNING INTO` を付けることで、追加したレコードの自動採番 ID などを変数に取得できます。

```sql
-- ============================================================
-- INSERT ... RETURNING INTO
-- ============================================================
-- 追加したレコードの自動採番 ID を変数に取得する

DO $$
DECLARE
    v_new_id INT;
    v_name   VARCHAR(100);
BEGIN
    INSERT INTO departments (name)
    VALUES ('RETURNING テスト部')
    RETURNING id, name INTO v_new_id, v_name;

    RAISE NOTICE '追加成功: ID=%, 名前=%', v_new_id, v_name;

    DELETE FROM departments WHERE id = v_new_id;
END;
$$;
```

## 2. UPDATE ... RETURNING INTO

**ファイル:** `sql/2-returning-into/2-update-returning.sql`

`UPDATE` 文で `RETURNING INTO` を使うと、更新後の値を変数に取得できます。`FOUND` と組み合わせて更新対象の有無を確認します。

```sql
-- ============================================================
-- UPDATE ... RETURNING INTO
-- ============================================================
-- 更新後の値を変数に取得する

DO $$
DECLARE
    v_task_id INT;
    v_new_status VARCHAR(20);
BEGIN
    UPDATE tasks
    SET status = 'in_progress', updated_at = CURRENT_TIMESTAMP
    WHERE id = (SELECT id FROM tasks WHERE status = 'todo' ORDER BY id LIMIT 1)
    RETURNING id, status INTO v_task_id, v_new_status;

    IF FOUND THEN
        RAISE NOTICE 'タスクID=% のステータスを % に変更しました', v_task_id, v_new_status;
    ELSE
        RAISE NOTICE '対象のタスクが見つかりません';
    END IF;
END;
$$;
```

## 3. DELETE ... RETURNING INTO

**ファイル:** `sql/2-returning-into/3-delete-returning.sql`

`DELETE` 文で `RETURNING INTO` を使うと、削除した行の値を変数に取得できます。削除内容のログ出力などに活用できます。

```sql
-- ============================================================
-- DELETE ... RETURNING INTO
-- ============================================================
-- 削除した行の値を変数に取得する

DO $$
DECLARE
    v_deleted_id  INT;
    v_deleted_msg TEXT;
BEGIN
    DELETE FROM job_logs
    WHERE id = (SELECT MAX(id) FROM job_logs)
    RETURNING id, message INTO v_deleted_id, v_deleted_msg;

    IF FOUND THEN
        RAISE NOTICE '削除したログ: ID=%, メッセージ=%', v_deleted_id, COALESCE(v_deleted_msg, '(なし)');
    END IF;
END;
$$;
```

## 4. RETURNING * INTO で行全体を取得

**ファイル:** `sql/2-returning-into/4-returning-rowtype.sql`

`RETURNING * INTO` と `%ROWTYPE` 変数を組み合わせることで、行全体をまるごと格納できます。

```sql
-- ============================================================
-- RETURNING * INTO で行全体を取得
-- ============================================================
-- %ROWTYPE 変数に行をまるごと格納する

DO $$
DECLARE
    v_dept departments%ROWTYPE;
BEGIN
    INSERT INTO departments (name)
    VALUES ('行全体テスト部')
    RETURNING * INTO v_dept;

    RAISE NOTICE 'ID=%, 名前=%, 作成日時=%', v_dept.id, v_dept.name, v_dept.created_at;

    DELETE FROM departments WHERE id = v_dept.id;
END;
$$;
```

## 5. RETURNING INTO STRICT

**ファイル:** `sql/2-returning-into/5-returning-strict.sql`

`STRICT` を付けると、結果が 0 行または 2 行以上の場合に例外が発生します。正確に 1 行であることを保証したい場合に使います。

```sql
-- ============================================================
-- RETURNING INTO STRICT
-- ============================================================
-- STRICT を付けると 0 行または 2 行以上で例外が発生する

DO $$
DECLARE
    v_task tasks%ROWTYPE;
BEGIN
    UPDATE tasks
    SET updated_at = CURRENT_TIMESTAMP
    WHERE id = 99999
    RETURNING * INTO STRICT v_task;

    RAISE NOTICE 'タスク: %', v_task.title;
EXCEPTION
    WHEN no_data_found THEN
        RAISE NOTICE '更新対象が見つかりません (0行)';
    WHEN too_many_rows THEN
        RAISE NOTICE '更新対象が複数あります';
END;
$$;
```

---

← [前へ: PERFORM](1-perform.md) | [ADVANCED_CONTROL](README.md) | [次へ: 動的 SQL (EXECUTE)](3-dynamic-sql.md) →
