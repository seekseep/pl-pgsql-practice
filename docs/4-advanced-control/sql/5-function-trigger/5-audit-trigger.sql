-- ============================================================
-- 監査ログトリガー
-- ============================================================

-- 監査ログテーブル (存在しない場合のみ作成)
CREATE TABLE IF NOT EXISTS audit_logs (
    id          SERIAL PRIMARY KEY,
    table_name  TEXT        NOT NULL,
    operation   TEXT        NOT NULL,
    record_id   INT,
    old_data    JSONB,
    new_data    JSONB,
    changed_at  TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION trigger_audit_log()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit_logs (table_name, operation, record_id, new_data)
        VALUES (TG_TABLE_NAME, TG_OP, NEW.id, to_jsonb(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_logs (table_name, operation, record_id, old_data, new_data)
        VALUES (TG_TABLE_NAME, TG_OP, NEW.id, to_jsonb(OLD), to_jsonb(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit_logs (table_name, operation, record_id, old_data)
        VALUES (TG_TABLE_NAME, TG_OP, OLD.id, to_jsonb(OLD));
        RETURN OLD;
    END IF;
END;
$$;

-- departments テーブルに監査トリガーを設定
DROP TRIGGER IF EXISTS trg_departments_audit ON departments;
CREATE TRIGGER trg_departments_audit
    AFTER INSERT OR UPDATE OR DELETE ON departments
    FOR EACH ROW
    EXECUTE FUNCTION trigger_audit_log();

-- 動作確認
DO $$
DECLARE
    v_rec RECORD;
BEGIN
    -- テスト用の更新
    UPDATE departments SET name = name WHERE id = 1;

    -- 監査ログを確認
    FOR v_rec IN
        SELECT operation, record_id, changed_at
        FROM audit_logs
        WHERE table_name = 'departments'
        ORDER BY id DESC
        LIMIT 3
    LOOP
        RAISE NOTICE '操作: % | レコードID: % | 日時: %',
            v_rec.operation, v_rec.record_id, v_rec.changed_at;
    END LOOP;
END;
$$;

-- クリーンアップ (トリガーを削除)
DROP TRIGGER IF EXISTS trg_departments_audit ON departments;
