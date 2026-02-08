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
