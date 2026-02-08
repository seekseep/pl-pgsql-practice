-- 複数行の INSERT
-- プロジェクトを一度に複数件追加する
INSERT INTO projects (name, description, status, start_date)
VALUES
    ('新規Webサービス開発', 'BtoC 向け新規サービス', 'planning', '2026-05-01'),
    ('社内ツール改善', '業務効率化ツールのリニューアル', 'planning', '2026-06-01'),
    ('データ分析基盤構築', '全社データの可視化基盤', 'planning', '2026-07-01');
