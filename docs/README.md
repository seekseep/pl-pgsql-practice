# ドキュメント目次

## 学習の流れ

上から順に進めてください。各セクションは前のセクションで学んだ構文だけを使って書かれています。

| # | セクション | 内容 |
|---|---|---|
| 0 | [セットアップ](0-setup/README.md) | Docker 起動、テーブル作成、シードデータ投入 |
| 1 | [データベース定義](1-database/README.md) | ER 図、テーブル定義、サンプルデータの確認 |
| 2 | [SQL 基礎](2-basic/README.md) | SELECT / INSERT / UPDATE / DELETE の基本操作 |
| 3 | [PL/pgSQL 基本制御](3-basic-control/README.md) | 変数、条件分岐、ループ、カーソル、例外処理 |
| 4 | [PostgreSQL 固有機能](4-advanced-control/README.md) | PERFORM、動的 SQL、配列/JSON、CTE、関数/トリガー |
| 5 | [実践課題](5-practice/README.md) | 学んだ知識を組み合わせた総合課題 (6 題 + 発展課題) |

## 各セクションの構成

セクション 2〜5 は同じ構成になっています。

```
<セクション>/
├── README.md          # 目次 (トピック一覧)
├── 0-<トピック>.md    # 解説 (説明 + 実際の SQL コード)
├── 1-<トピック>.md
├── ...
└── sql/               # 実行用 SQL ファイル
    ├── 0-<トピック>/
    ├── 1-<トピック>/
    └── ...
```

- **README.md** — そのセクションのトピック一覧と概要
- **トピック `.md`** — 1 テーマにつき 1 ファイル。解説と実際の SQL コードを掲載
- **`sql/`** — psql で直接実行できる SQL ファイル。トピックごとにサブディレクトリに分類

## ディレクトリ構成

```
docs/
├── 0-setup/                          # セットアップ
│   ├── README.md                     #   セットアップ手順
│   └── sql/
│       ├── 0-definition.sql          #   テーブル定義
│       └── 1-seeds.sql               #   シードデータ
├── 1-database/                       # データベース定義書
│   └── README.md                     #   ER 図・テーブル定義・サンプルデータ
├── 2-basic/                          # SQL 基礎
│   ├── README.md                     #   目次
│   ├── 0-select.md                   #   SELECT
│   ├── 1-insert.md                   #   INSERT
│   ├── 2-update.md                   #   UPDATE
│   ├── 3-delete.md                   #   DELETE
│   └── sql/
│       ├── 0-select/                 #   SELECT (21 ファイル)
│       ├── 1-insert/                 #   INSERT (7 ファイル)
│       ├── 2-update/                 #   UPDATE (8 ファイル)
│       └── 3-delete/                 #   DELETE (8 ファイル)
├── 3-basic-control/                  # PL/pgSQL 基本制御
│   ├── README.md                     #   目次
│   ├── 0-variables.md                #   変数
│   ├── 1-condition.md                #   条件分岐
│   ├── 2-loop.md                     #   ループ
│   ├── 3-cursor.md                   #   カーソル
│   ├── 4-exception.md                #   例外処理
│   └── sql/
│       ├── 0-variables/              #   変数 (8 ファイル)
│       ├── 1-condition/              #   条件分岐 (8 ファイル)
│       ├── 2-loop/                   #   ループ (9 ファイル)
│       ├── 3-cursor/                 #   カーソル (6 ファイル)
│       └── 4-exception/              #   例外処理 (9 ファイル)
├── 4-advanced-control/               # PostgreSQL 固有機能
│   ├── README.md                     #   目次
│   ├── 0-perform.md                  #   PERFORM
│   ├── 1-returning-into.md           #   RETURNING INTO
│   ├── 2-dynamic-sql.md              #   動的 SQL
│   ├── 3-array-json.md               #   配列 / JSON
│   ├── 4-cte-window.md               #   CTE / ウィンドウ関数
│   ├── 5-function-trigger.md         #   関数 / トリガー
│   └── sql/
│       ├── 0-perform/                #   PERFORM (4 ファイル)
│       ├── 1-returning-into/         #   RETURNING INTO (5 ファイル)
│       ├── 2-dynamic-sql/            #   動的 SQL (7 ファイル)
│       ├── 3-array-json/             #   配列 / JSON (10 ファイル)
│       ├── 4-cte-window/             #   CTE / ウィンドウ関数 (7 ファイル)
│       └── 5-function-trigger/       #   関数 / トリガー (7 ファイル)
└── 5-practice/                       # 実践課題
    ├── README.md                     #   目次
    ├── 0-department-report.md        #   部署レポート ★☆☆
    ├── 1-project-dashboard.md        #   プロジェクトダッシュボード ★★☆
    ├── 2-employee-transfer.md        #   従業員異動処理 ★★☆
    ├── 3-task-auto-assign.md         #   タスク自動割り当て ★★★
    ├── 4-job-executor.md             #   ジョブ実行シミュレーター ★★★
    ├── 5-monthly-summary.md          #   月次サマリーレポート ★★★
    └── sql/
        ├── 0-department-report/      #   部署レポート
        ├── 1-project-dashboard/      #   プロジェクトダッシュボード
        ├── 2-employee-transfer/      #   従業員異動処理
        ├── 3-task-auto-assign/       #   タスク自動割り当て
        ├── 4-job-executor/           #   ジョブ実行シミュレーター
        └── 5-monthly-summary/        #   月次サマリーレポート
```
