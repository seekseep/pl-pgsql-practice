# セットアップ手順

全てのコマンドはプロジェクトルート (`docker-compose.yml` があるディレクトリ) で実行してください。

## 環境変数ファイルの作成

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

## Docker で PostgreSQL を起動

```bash
docker compose up -d
```

起動を確認します。

```bash
docker compose ps
```

`running` と表示されれば OK です。

## DB に接続

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB"
```

パスワードを聞かれたら `.env` の `POSTGRES_PASSWORD` の値を入力してください。
`practice=#` のようなプロンプトが表示されれば接続成功です。

## テーブル定義の実行

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/1-setup/sql/1-definition.sql
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

## シードデータの投入

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/1-setup/sql/2-seeds.sql
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

## SQL の実行方法

psql にログインして、各セクションの SQL を貼り付けて実行します。

### 1. psql にログインする

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB"
```

### 2. SQL を貼り付けて実行する

psql プロンプトが表示されたら、各セクションの SQL をコピーして貼り付けます。

```
practice=# SELECT * FROM departments;
```

複数行の SQL もそのまま貼り付けて実行できます。

```
practice=# DO $$
practice$# DECLARE
practice$#   v_name TEXT := 'テスト';
practice$# BEGIN
practice$#   RAISE NOTICE '名前: %', v_name;
practice$# END;
practice$# $$;
```

### 3. psql を終了する

```
practice=# \q
```

## やり直す場合

データを全て削除して最初からやり直すには、Docker のボリュームごと削除します。

```bash
docker compose down -v
docker compose up -d
```

起動後、テーブル定義・シードデータの投入を再度実行してください。

## 停止

```bash
docker compose down
```
