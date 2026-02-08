# 課題 4: ジョブ実行シミュレーター

難易度: ★★★

## 目標

ジョブの実行をシミュレートし、ジョブの種類（`job_type`）に応じた処理を `CASE` 分岐で実行する関数を作成する。実行結果は `job_logs` テーブルに記録し、エラーが発生した場合も失敗ログとして記録する。

## 要件

1. ジョブ ID を引数として受け取る
2. ジョブが存在しない場合は `RAISE EXCEPTION` でエラーを発生させる
3. ジョブが無効（`is_enabled = FALSE`）の場合はエラーを発生させる
4. 実行開始時に `job_logs` へ `running` ステータスのログを `RETURNING INTO` で挿入する
5. `job_type` に応じて `CASE` で処理を分岐する:
   - `daily_report`: 部署ごとのタスク完了数を集計する
   - `data_sync`: 全テーブルのレコード数を集計する
   - `cleanup`: 30日以前の古いジョブログの件数を報告する
   - その他: 不明なジョブタイプとしてメッセージを設定する
6. 成功時は `job_logs` のステータスを `success` に更新し、`jobs` の `last_run_at` を更新する
7. `EXCEPTION WHEN OTHERS` ブロックで失敗時のログを `failure` として記録する

## 使用する知識

- `CASE` 文（`CASE ... WHEN ... THEN ... END CASE`）による分岐処理
- `INSERT ... RETURNING INTO` によるログ ID の取得
- `EXCEPTION WHEN OTHERS` によるエラーハンドリング
- `SQLERRM` によるエラーメッセージの取得
- `FOR ... IN SELECT ... LOOP` によるカーソルループ
- `pg_stat_user_tables` システムカタログの参照
- `RECORD` 型変数の活用

## 解答例

**ファイル:** `sql/4-job-executor/0-job-executor.sql`

```sql
-- ============================================================
-- 課題 4: ジョブ実行シミュレーター
-- ============================================================
-- ジョブの実行をシミュレートし、結果を job_logs に記録する関数
-- 学習ポイント: CASE 分岐, RETURNING INTO, EXCEPTION

CREATE OR REPLACE FUNCTION execute_job(p_job_id INT)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_job      RECORD;
    v_log_id   INT;
    v_message  TEXT := '';
    v_rec      RECORD;
BEGIN
    -- ジョブの存在と有効チェック
    SELECT * INTO v_job FROM jobs WHERE id = p_job_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'ジョブID=% は存在しません', p_job_id;
    END IF;

    IF NOT v_job.is_enabled THEN
        RAISE EXCEPTION 'ジョブ「%」は無効です', v_job.name;
    END IF;

    -- 実行ログを追加 (running)
    INSERT INTO job_logs (job_id, status, started_at, message)
    VALUES (p_job_id, 'running', CURRENT_TIMESTAMP, '実行開始')
    RETURNING id INTO v_log_id;

    RAISE NOTICE '[%] ジョブ「%」を実行開始', v_job.job_type, v_job.name;

    -- job_type に応じた処理
    CASE v_job.job_type
        WHEN 'daily_report' THEN
            -- 部署ごとのタスク完了数を集計
            FOR v_rec IN
                SELECT d.name, COUNT(t.id) AS done_count
                FROM departments d
                LEFT JOIN employees e ON d.id = e.department_id
                LEFT JOIN tasks t ON e.id = t.assignee_id AND t.status = 'done'
                GROUP BY d.id, d.name
                ORDER BY d.id
            LOOP
                v_message := v_message || v_rec.name || ': '
                    || v_rec.done_count || '件完了 / ';
            END LOOP;

        WHEN 'data_sync' THEN
            -- 全テーブルのレコード数を集計
            FOR v_rec IN
                SELECT relname AS table_name,
                       n_live_tup AS row_count
                FROM pg_stat_user_tables
                WHERE schemaname = 'public'
                ORDER BY relname
            LOOP
                v_message := v_message || v_rec.table_name || ': '
                    || v_rec.row_count || '行 / ';
            END LOOP;

        WHEN 'cleanup' THEN
            -- 古いジョブログの件数を報告
            SELECT COUNT(*) INTO v_rec
            FROM job_logs
            WHERE created_at < CURRENT_TIMESTAMP - INTERVAL '30 days';

            v_message := '30日以前のログ: ' || COALESCE(v_rec.count, 0) || '件';

        ELSE
            v_message := '不明なジョブタイプ: ' || v_job.job_type;
    END CASE;

    -- 成功: ログを更新
    UPDATE job_logs
    SET status = 'success',
        finished_at = CURRENT_TIMESTAMP,
        message = v_message
    WHERE id = v_log_id;

    -- jobs の last_run_at を更新
    UPDATE jobs
    SET last_run_at = CURRENT_TIMESTAMP
    WHERE id = p_job_id;

    RAISE NOTICE '実行結果: %', v_message;
    RAISE NOTICE 'ジョブ「%」が正常に完了しました', v_job.name;

EXCEPTION
    WHEN OTHERS THEN
        -- 失敗: ログを更新
        UPDATE job_logs
        SET status = 'failure',
            finished_at = CURRENT_TIMESTAMP,
            message = SQLERRM
        WHERE id = v_log_id;

        RAISE NOTICE 'ジョブ「%」が失敗しました: %', v_job.name, SQLERRM;
END;
$$;

-- 実行テスト
SELECT execute_job(1);
SELECT execute_job(2);

-- クリーンアップ
DROP FUNCTION IF EXISTS execute_job(INT);
```

## 実行方法

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/5-practice/sql/4-job-executor/0-job-executor.sql
```

---

← [前へ](3-task-auto-assign.md) | [PRACTICE](README.md) | [次へ](5-monthly-summary.md) →
