# セットアップ手順

Docker で PostgreSQL を立ち上げ、テーブル作成・データ投入までの流れです。

## 1. 環境変数ファイルの作成

```bash
bash scripts/setup-env.sh
```

対話形式で以下の値を設定します (デフォルト値はそのまま Enter で OK)。

| 変数名 | デフォルト | 説明 |
|---|---|---|
| POSTGRES_USER | postgres | DB ユーザー名 |
| POSTGRES_PASSWORD | postgres | DB パスワード |
| POSTGRES_DB | practice | DB 名 |
| POSTGRES_PORT | 5432 | ホスト側ポート |

対話をスキップする場合は `-y` オプションでデフォルト値が使われます。

```bash
bash scripts/setup-env.sh -y
```

## 2. Docker で PostgreSQL を起動

```bash
docker compose up -d
```

起動を確認します。

```bash
docker compose ps
```

`running` と表示されれば OK です。

## 3. DB に接続

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB"
```

パスワードを聞かれたら `.env` の `POSTGRES_PASSWORD` の値を入力してください。
`practice=#` のようなプロンプトが表示されれば接続成功です。

## 4. テーブル定義の実行

`sql/0-definition.sql` を実行してテーブルを作成します。

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/0-setup/sql/0-definition.sql
```

作成されるテーブル:

| テーブル | 説明 |
|---|---|
| departments | 部署 |
| employees | 従業員 |
| projects | プロジェクト |
| project_members | プロジェクトメンバー (多対多) |
| tasks | タスク |
| jobs | ジョブ定義 |
| job_logs | ジョブ実行ログ |

テーブルが作成されたか確認するには、psql 上で `\dt` を実行します。

```
practice=# \dt
```

## 5. シードデータの投入

`sql/1-seeds.sql` を実行してサンプルデータを投入します。

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/0-setup/sql/1-seeds.sql
```

投入されるデータ:

| テーブル | 件数 |
|---|---|
| departments | 10 |
| employees | 100 |
| projects | 20 |
| project_members | 119 |
| tasks | 270 |
| jobs | 10 |
| job_logs | 335 |

データが入ったか確認するには、psql 上でカウントを取ります。

```sql
SELECT
    'departments' AS table_name, COUNT(*) FROM departments
UNION ALL SELECT
    'employees', COUNT(*) FROM employees
UNION ALL SELECT
    'projects', COUNT(*) FROM projects
UNION ALL SELECT
    'project_members', COUNT(*) FROM project_members
UNION ALL SELECT
    'tasks', COUNT(*) FROM tasks
UNION ALL SELECT
    'jobs', COUNT(*) FROM jobs
UNION ALL SELECT
    'job_logs', COUNT(*) FROM job_logs;
```

## まとめて実行

手順 4・5 をまとめて実行する場合:

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/0-setup/sql/0-definition.sql \
  -f docs/0-setup/sql/1-seeds.sql
```

## SQL ファイルの実行方法

各セクションの SQL ファイルは以下のように実行します。

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/2-basic/sql/0-select.sql
```

または psql に接続した状態で `\i` コマンドを使います。

```
practice=# \i docs/2-basic/sql/0-select.sql
```

## やり直す場合

データを全て削除して最初からやり直すには、Docker のボリュームごと削除します。

```bash
docker compose down -v
docker compose up -d
```

起動後、手順 4・5 を再度実行してください。

## ディレクトリ構成

```
docs/
├── 0-setup/                          # セットアップ
│   ├── README.md                     #   セットアップ手順
│   └── sql/
│       ├── 0-definition.sql          #   テーブル定義
│       └── 1-seeds.sql               #   シードデータ
├── 1-database/                       # データベース定義書
│   └── README.md                     #   テーブル定義・ER図・サンプルデータ
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
