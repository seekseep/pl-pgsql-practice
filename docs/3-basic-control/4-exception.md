# 例外処理

> ※ これまでの全ての構文を使用

## 0. 基本的な例外処理

**ファイル:** `sql/4-exception/0-basic-exception.sql`

`BEGIN ... EXCEPTION WHEN ... THEN` でエラーをキャッチする基本的な方法を示します。ゼロ除算エラーを `division_by_zero` で捕捉します。

```sql
-- ============================================================
-- 基本的な例外処理
-- ============================================================
-- BEGIN ... EXCEPTION WHEN ... THEN でエラーをキャッチする

DO $$
DECLARE
    v_result INT;
BEGIN
    v_result := 10 / 0;
    RAISE NOTICE '結果: %', v_result;
EXCEPTION
    WHEN division_by_zero THEN
        RAISE NOTICE 'エラー: ゼロで割ることはできません';
END;
$$;
```

### 実行方法

> GUI ツール（pgAdmin, DBeaver 等）では、上記の SQL をクエリエディタに貼り付けて実行できます。

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/3-basic-control/sql/4-exception/0-basic-exception.sql
```

## 1. 複数の例外をキャッチ

**ファイル:** `sql/4-exception/1-multiple-exceptions.sql`

`WHEN` を複数書いて、例外の種類ごとに処理を分ける方法を示します。`INTO STRICT` を使い、`no_data_found` と `too_many_rows` を個別にハンドリングします。

```sql
-- ============================================================
-- 複数の例外をキャッチ
-- ============================================================
-- WHEN を複数書いて、例外の種類ごとに処理を分ける

DO $$
DECLARE
    v_emp employees%ROWTYPE;
BEGIN
    -- INTO STRICT: 結果が 0 行 or 2 行以上で例外
    SELECT * INTO STRICT v_emp FROM employees WHERE id = 99999;
    RAISE NOTICE '従業員: % %', v_emp.last_name, v_emp.first_name;
EXCEPTION
    WHEN no_data_found THEN
        RAISE NOTICE 'エラー: 該当する従業員が見つかりません';
    WHEN too_many_rows THEN
        RAISE NOTICE 'エラー: 複数のレコードが該当しました';
END;
$$;
```

### 実行方法

> GUI ツール（pgAdmin, DBeaver 等）では、上記の SQL をクエリエディタに貼り付けて実行できます。

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/3-basic-control/sql/4-exception/1-multiple-exceptions.sql
```

## 2. SQLSTATE と SQLERRM

**ファイル:** `sql/4-exception/2-sqlstate-sqlerrm.sql`

`WHEN OTHERS` で全ての例外をキャッチし、`SQLSTATE` と `SQLERRM` で詳細情報を取得する方法を示します。

```sql
-- ============================================================
-- SQLSTATE と SQLERRM
-- ============================================================
-- WHEN OTHERS で全ての例外をキャッチし、詳細を取得する

DO $$
DECLARE
    v_emp employees%ROWTYPE;
BEGIN
    SELECT * INTO STRICT v_emp FROM employees WHERE id = 99999;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'SQLSTATE: %', SQLSTATE;
        RAISE NOTICE 'エラーメッセージ: %', SQLERRM;
END;
$$;
```

### 実行方法

> GUI ツール（pgAdmin, DBeaver 等）では、上記の SQL をクエリエディタに貼り付けて実行できます。

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/3-basic-control/sql/4-exception/2-sqlstate-sqlerrm.sql
```

## 3. RAISE EXCEPTION (カスタムエラー)

**ファイル:** `sql/4-exception/3-raise-exception.sql`

`RAISE EXCEPTION` で独自のエラーを発生させる方法を示します。プロジェクトメンバーの上限チェックをバリデーションとして実装しています。

```sql
-- ============================================================
-- RAISE EXCEPTION (カスタムエラー)
-- ============================================================
-- RAISE EXCEPTION で独自のエラーを発生させる

DO $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM project_members
    WHERE project_id = 1;

    IF v_count > 100 THEN
        RAISE EXCEPTION 'プロジェクトメンバーが上限 (100人) を超えています: % 人', v_count;
    END IF;

    RAISE NOTICE 'メンバー数: % 人 (上限内)', v_count;
EXCEPTION
    WHEN raise_exception THEN
        RAISE NOTICE 'バリデーションエラー: %', SQLERRM;
END;
$$;
```

### 実行方法

> GUI ツール（pgAdmin, DBeaver 等）では、上記の SQL をクエリエディタに貼り付けて実行できます。

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/3-basic-control/sql/4-exception/3-raise-exception.sql
```

## 4. RAISE のレベル

**ファイル:** `sql/4-exception/4-raise-levels.sql`

`RAISE` の 6 段階のレベル（`DEBUG`、`LOG`、`INFO`、`NOTICE`、`WARNING`、`EXCEPTION`）を示します。レベルによって出力先や処理の中断有無が異なります。

```sql
-- ============================================================
-- RAISE のレベル
-- ============================================================
-- 6 段階のレベルがある: DEBUG, LOG, INFO, NOTICE, WARNING, EXCEPTION

DO $$
BEGIN
    RAISE DEBUG   'デバッグ情報 (通常非表示)';
    RAISE LOG     'ログ情報 (サーバーログに出力)';
    RAISE INFO    'インフォメーション';
    RAISE NOTICE  'ノーティス (デフォルトで表示)';
    RAISE WARNING 'ワーニング: 注意が必要です';
    -- RAISE EXCEPTION は処理を中断するため、最後に試す場合のみ有効化
    -- RAISE EXCEPTION 'エラー: 処理を中断します';
END;
$$;
```

### 実行方法

> GUI ツール（pgAdmin, DBeaver 等）では、上記の SQL をクエリエディタに貼り付けて実行できます。

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/3-basic-control/sql/4-exception/4-raise-levels.sql
```

## 5. サブブロックでの例外処理

**ファイル:** `sql/4-exception/5-subblock.sql`

ループ内で `BEGIN...EXCEPTION` サブブロックを使い、エラーが起きても他の反復は続行する方法を示します。部署ごとの処理でエラーが発生してもスキップして次の部署を処理します。

```sql
-- ============================================================
-- サブブロックでの例外処理
-- ============================================================
-- ループ内で BEGIN...EXCEPTION を使い、エラーが起きても他の反復は続行する

DO $$
DECLARE
    v_rec RECORD;
BEGIN
    FOR v_rec IN SELECT id, name FROM departments ORDER BY id LOOP
        BEGIN
            IF v_rec.id = 3 THEN
                RAISE EXCEPTION '部署 % でエラー発生', v_rec.name;
            END IF;

            RAISE NOTICE '部署 % の処理完了', v_rec.name;
        EXCEPTION
            WHEN raise_exception THEN
                RAISE NOTICE '※ 部署 % の処理でエラー: % (スキップ)', v_rec.name, SQLERRM;
        END;
    END LOOP;

    RAISE NOTICE '全部署の処理が完了しました';
END;
$$;
```

### 実行方法

> GUI ツール（pgAdmin, DBeaver 等）では、上記の SQL をクエリエディタに貼り付けて実行できます。

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/3-basic-control/sql/4-exception/5-subblock.sql
```

## 6. UNIQUE 制約違反のハンドリング

**ファイル:** `sql/4-exception/6-unique-violation.sql`

`unique_violation` で重複エラーをキャッチする方法を示します。既に存在するメールアドレスで INSERT を試み、重複時にエラーメッセージを表示します。

```sql
-- ============================================================
-- UNIQUE 制約違反のハンドリング
-- ============================================================
-- unique_violation で重複エラーをキャッチする

DO $$
BEGIN
    -- 既に存在するメールアドレスで INSERT を試みる
    INSERT INTO employees (department_id, last_name, first_name, email, hire_date)
    VALUES (1, 'テスト', '太郎', 'emp0001@example.com', CURRENT_DATE);

    RAISE NOTICE '従業員を追加しました';
EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'エラー: そのメールアドレスは既に使われています';
END;
$$;
```

### 実行方法

> GUI ツール（pgAdmin, DBeaver 等）では、上記の SQL をクエリエディタに貼り付けて実行できます。

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/3-basic-control/sql/4-exception/6-unique-violation.sql
```

## 7. FK 制約違反のハンドリング

**ファイル:** `sql/4-exception/7-fk-violation.sql`

`foreign_key_violation` で外部キーエラーをキャッチする方法を示します。存在しない部署 ID で INSERT を試み、FK 制約違反時にエラーメッセージを表示します。

```sql
-- ============================================================
-- FK 制約違反のハンドリング
-- ============================================================
-- foreign_key_violation で外部キーエラーをキャッチする

DO $$
BEGIN
    -- 存在しない部署 ID で INSERT を試みる
    INSERT INTO employees (department_id, last_name, first_name, email, hire_date)
    VALUES (9999, 'テスト', '次郎', 'test.jiro@example.com', CURRENT_DATE);

    RAISE NOTICE '従業員を追加しました';
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'エラー: 指定された部署が存在しません (department_id=9999)';
END;
$$;
```

### 実行方法

> GUI ツール（pgAdmin, DBeaver 等）では、上記の SQL をクエリエディタに貼り付けて実行できます。

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/3-basic-control/sql/4-exception/7-fk-violation.sql
```

## 8. GET STACKED DIAGNOSTICS

**ファイル:** `sql/4-exception/8-get-diagnostics.sql`

`GET STACKED DIAGNOSTICS` で例外の詳細情報（SQLSTATE、メッセージ、詳細、ヒント、コンテキスト）を取得する方法を示します。デバッグやログ出力に役立つ詳細な例外情報を得られます。

```sql
-- ============================================================
-- GET STACKED DIAGNOSTICS
-- ============================================================
-- 例外の詳細情報 (SQLSTATE, メッセージ, 詳細, ヒント, コンテキスト) を取得する

DO $$
DECLARE
    v_state   TEXT;
    v_msg     TEXT;
    v_detail  TEXT;
    v_hint    TEXT;
    v_context TEXT;
BEGIN
    INSERT INTO employees (department_id, last_name, first_name, email, hire_date)
    VALUES (9999, 'テスト', '三郎', 'test.saburo@example.com', CURRENT_DATE);
EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS
            v_state   = RETURNED_SQLSTATE,
            v_msg     = MESSAGE_TEXT,
            v_detail  = PG_EXCEPTION_DETAIL,
            v_hint    = PG_EXCEPTION_HINT,
            v_context = PG_EXCEPTION_CONTEXT;

        RAISE NOTICE 'SQLSTATE : %', v_state;
        RAISE NOTICE 'メッセージ : %', v_msg;
        RAISE NOTICE '詳細     : %', v_detail;
        RAISE NOTICE 'ヒント   : %', v_hint;
        RAISE NOTICE 'コンテキスト: %', v_context;
END;
$$;
```

### 実行方法

> GUI ツール（pgAdmin, DBeaver 等）では、上記の SQL をクエリエディタに貼り付けて実行できます。

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/3-basic-control/sql/4-exception/8-get-diagnostics.sql
```

---

← [前へ: カーソル](3-cursor.md) | [BASIC_CONTROL](README.md)
