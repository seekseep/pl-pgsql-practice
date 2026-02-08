# ドキュメント目次

## 学習の流れ

上から順に進めてください。各セクションは前のセクションで学んだ構文だけを使って書かれています。

| # | セクション | 内容 |
|---|---|---|
| 1 | [セットアップ](1-setup/README.md) | Docker 起動、テーブル作成、シードデータ投入 |
| 2 | [データベース定義](2-database/README.md) | ER 図、テーブル定義、サンプルデータの確認 |
| 3 | [SQL 基礎](3-basic/README.md) | SELECT / INSERT / UPDATE / DELETE の基本操作 |
| 4 | [PL/pgSQL 基本制御](4-basic-control/README.md) | 変数、条件分岐、ループ、カーソル、例外処理 |
| 5 | [PostgreSQL 固有機能](5-advanced-control/README.md) | PERFORM、動的 SQL、配列/JSON、CTE、関数/トリガー |
| 6 | [実践課題](6-practice/README.md) | 学んだ知識を組み合わせた総合課題 (6 題 + 発展課題) |

## 各セクションの構成

セクション 3〜6 は同じ構成になっています。

```
<セクション>/
├── README.md          # 目次 (トピック一覧)
├── 1-<トピック>.md    # 解説 (説明 + 実際の SQL コード)
├── 2-<トピック>.md
├── ...
└── sql/               # 実行用 SQL ファイル
    ├── 1-<トピック>/
    ├── 2-<トピック>/
    └── ...
```

- **README.md** — そのセクションのトピック一覧と概要
- **トピック `.md`** — 1 テーマにつき 1 ファイル。解説と実際の SQL コードを掲載
- **`sql/`** — psql で直接実行できる SQL ファイル。トピックごとにサブディレクトリに分類

## ディレクトリ構成

```
docs/
├── 1-setup/                          # セットアップ
│   ├── README.md                     #   セットアップ手順
│   └── sql/
│       ├── 1-definition.sql          #   テーブル定義
│       └── 2-seeds.sql               #   シードデータ
├── 2-database/                       # データベース定義書
│   └── README.md                     #   ER 図・テーブル定義・サンプルデータ
├── 3-basic/                          # SQL 基礎
│   ├── README.md                     #   目次
│   ├── 1-basic-select.md             #   SELECT 基礎
│   ├── 2-advanced-select.md          #   SELECT 応用
│   ├── 3-insert.md                   #   INSERT
│   ├── 4-update.md                   #   UPDATE
│   ├── 5-delete.md                   #   DELETE
│   └── sql/
│       ├── 1-select/                 #   SELECT (21 ファイル)
│       ├── 2-insert/                 #   INSERT (7 ファイル)
│       ├── 3-update/                 #   UPDATE (8 ファイル)
│       └── 4-delete/                 #   DELETE (8 ファイル)
├── 4-basic-control/                  # PL/pgSQL 基本制御
│   ├── README.md                     #   目次
│   ├── 1-raise.md                    #   RAISE
│   ├── 2-variables.md                #   変数
│   ├── 3-condition.md                #   条件分岐
│   ├── 4-loop.md                     #   ループ
│   ├── 5-cursor.md                   #   カーソル
│   ├── 6-exception.md                #   例外処理
│   └── sql/
│       ├── 1-variables/              #   変数 (8 ファイル)
│       ├── 2-condition/              #   条件分岐 (8 ファイル)
│       ├── 3-loop/                   #   ループ (9 ファイル)
│       ├── 4-cursor/                 #   カーソル (6 ファイル)
│       └── 5-exception/              #   例外処理 (9 ファイル)
├── 5-advanced-control/               # PostgreSQL 固有機能
│   ├── README.md                     #   目次
│   ├── 1-perform.md                  #   PERFORM
│   ├── 2-returning-into.md           #   RETURNING INTO
│   ├── 3-dynamic-sql.md              #   動的 SQL
│   ├── 4-array-json.md               #   配列 / JSON
│   ├── 5-cte-window.md               #   CTE / ウィンドウ関数
│   ├── 6-function-trigger.md         #   関数 / トリガー
│   └── sql/
│       ├── 1-perform/                #   PERFORM (4 ファイル)
│       ├── 2-returning-into/         #   RETURNING INTO (5 ファイル)
│       ├── 3-dynamic-sql/            #   動的 SQL (7 ファイル)
│       ├── 4-array-json/             #   配列 / JSON (10 ファイル)
│       ├── 5-cte-window/             #   CTE / ウィンドウ関数 (7 ファイル)
│       └── 6-function-trigger/       #   関数 / トリガー (7 ファイル)
└── 6-practice/                       # 実践課題
    ├── README.md                     #   目次
    ├── 1-department-report.md        #   部署レポート ★☆☆
    ├── 2-project-dashboard.md        #   プロジェクトダッシュボード ★★☆
    ├── 3-employee-transfer.md        #   従業員異動処理 ★★☆
    ├── 4-task-auto-assign.md         #   タスク自動割り当て ★★★
    ├── 5-job-executor.md             #   ジョブ実行シミュレーター ★★★
    ├── 6-monthly-summary.md          #   月次サマリーレポート ★★★
    └── sql/
        ├── 1-department-report/      #   部署レポート
        ├── 2-project-dashboard/      #   プロジェクトダッシュボード
        ├── 3-employee-transfer/      #   従業員異動処理
        ├── 4-task-auto-assign/       #   タスク自動割り当て
        ├── 5-job-executor/           #   ジョブ実行シミュレーター
        └── 6-monthly-summary/        #   月次サマリーレポート
```
