# セットアップ手順

全てのコマンドはプロジェクトルート (`docker-compose.yml` があるディレクトリ) で実行してください。

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

## 5. シードデータの投入

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
  -f docs/2-basic/sql/0-select/0-select-all.sql
```

または psql に接続した状態で `\i` コマンドを使います。

```
practice=# \i docs/2-basic/sql/0-select/0-select-all.sql
```

## やり直す場合

データを全て削除して最初からやり直すには、Docker のボリュームごと削除します。

```bash
docker compose down -v
docker compose up -d
```

起動後、手順 4・5 を再度実行してください。

## 停止

```bash
docker compose down
```
