# 実践課題

これまで学んだ SQL と PL/pgSQL の知識を組み合わせて、実践的な課題に取り組みます。

---

## 課題一覧

| # | 課題 | 難易度 | 主な学習ポイント |
|---|---|---|---|
| 0 | [部署別レポート](0-department-report.md) | ★☆☆ | SELECT INTO, IF, RAISE NOTICE |
| 1 | [プロジェクトダッシュボード](1-project-dashboard.md) | ★★☆ | RETURNS TABLE, CTE, COALESCE |
| 2 | [従業員異動処理](2-employee-transfer.md) | ★★☆ | バリデーション, EXCEPTION |
| 3 | [タスク自動割り当て](3-task-auto-assign.md) | ★★★ | 配列, ラウンドロビン |
| 4 | [ジョブ実行シミュレーター](4-job-executor.md) | ★★★ | CASE, RETURNING INTO, 例外処理 |
| 5 | [月次サマリーレポート](5-monthly-summary.md) | ★★★ | JSONB, jsonb_build_object, jsonb_agg |

## 発展課題

基本課題をクリアした方向けの追加課題です。複数の機能を組み合わせた実践的な内容になっています。

| # | 課題 | ヒント |
|---|---|---|
| 1 | **プロジェクト完了ハンドラー** — プロジェクトの全タスクが `done` になったら自動的にプロジェクトのステータスを `completed` に更新するトリガーを作成 | `AFTER UPDATE ON tasks` トリガー + `NOT EXISTS` で未完了タスクをチェック |
| 2 | **従業員検索 API** — 名前・部署・入社日範囲を動的に組み合わせて検索できる `RETURNS TABLE` 関数を作成 | `format()` + `EXECUTE` で動的 SQL を構築、`NULL` パラメータは条件をスキップ |
| 3 | **タスク期限アラート** — 期限が近い（3 日以内）または期限切れのタスクを一覧表示し、担当者と上長に通知メッセージを生成する関数を作成 | `CURRENT_DATE` との比較、`CASE` で緊急度判定、`jsonb_agg` で通知データ構築 |
| 4 | **部署統合処理** — 2 つの部署を 1 つに統合する関数を作成（従業員の異動、プロジェクトメンバーの更新、統合元の部署を削除） | トランザクション内で複数テーブルを更新、`EXCEPTION` で安全にロールバック |
| 5 | **データ整合性チェック** — 全テーブルのデータ整合性を検証し、不整合を JSONB レポートとして返す関数を作成 | 外部キー整合性の手動チェック、`jsonb_build_object` + `jsonb_agg` でレポート生成 |

---

← [PostgreSQL 固有機能](../4-advanced-control/README.md)
