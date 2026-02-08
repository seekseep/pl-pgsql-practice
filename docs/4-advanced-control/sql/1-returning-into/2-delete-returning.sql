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
