# PERFORM

## 1. PERFORM の基本

**ファイル:** `sql/1-perform/1-basic.sql`

`PERFORM` は `SELECT` の結果を破棄して実行する PL/pgSQL 固有の構文です。関数の呼び出しや副作用のある処理で使います。

```sql
-- ============================================================
-- PERFORM の基本
-- ============================================================
-- PERFORM は SELECT の結果を破棄して実行する PL/pgSQL 固有の構文
-- 関数の呼び出しや副作用のある処理で使う

DO $$
BEGIN
    PERFORM pg_sleep(0.1);
    RAISE NOTICE '0.1秒待機しました';
END;
$$;
```

## 2. PERFORM + FOUND

**ファイル:** `sql/1-perform/2-found.sql`

`PERFORM` 実行後に `FOUND` を使うことで、対象レコードが存在したかどうかを確認できます。

```sql
-- ============================================================
-- PERFORM + FOUND
-- ============================================================
-- PERFORM 後に FOUND でレコードの存在を確認する

DO $$
BEGIN
    PERFORM 1 FROM employees WHERE id = 1;

    IF FOUND THEN
        RAISE NOTICE 'ID=1 の従業員は存在します';
    ELSE
        RAISE NOTICE 'ID=1 の従業員は存在しません';
    END IF;
END;
$$;
```

## 3. 存在チェックに PERFORM を使う

**ファイル:** `sql/1-perform/3-existence-check.sql`

レコードが存在しない場合に処理を分岐する実践的なパターンです。`NOT FOUND` を使って存在しないケースを検出します。

```sql
-- ============================================================
-- 存在チェックに PERFORM を使う
-- ============================================================
-- レコードがなければ処理を分岐するパターン

DO $$
DECLARE
    v_dept_id INT := 999;
BEGIN
    PERFORM 1 FROM departments WHERE id = v_dept_id;

    IF NOT FOUND THEN
        RAISE NOTICE '部署ID=% は存在しません。新規作成します。', v_dept_id;
    END IF;
END;
$$;
```

## 4. PERFORM で関数を呼び出す

**ファイル:** `sql/1-perform/4-function-call.sql`

戻り値が不要な関数呼び出しに `PERFORM` を使います。`set_config` のような設定関数の呼び出しに便利です。

```sql
-- ============================================================
-- PERFORM で関数を呼び出す
-- ============================================================
-- 戻り値が不要な関数呼び出しに使う

DO $$
DECLARE
    v_rec RECORD;
BEGIN
    FOR v_rec IN SELECT id, name FROM departments ORDER BY id LIMIT 3 LOOP
        PERFORM set_config('app.current_dept', v_rec.name, TRUE);
        RAISE NOTICE '処理中の部署: % (設定に保存)', v_rec.name;
    END LOOP;

    RAISE NOTICE '最後に設定された部署: %', current_setting('app.current_dept');
END;
$$;
```

---

[ADVANCED_CONTROL](README.md) | [次へ: RETURNING INTO](2-returning-into.md) →
