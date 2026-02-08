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
