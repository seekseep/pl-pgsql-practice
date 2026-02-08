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
