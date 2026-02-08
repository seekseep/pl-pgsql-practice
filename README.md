# PL/pgSQL Practice

Docker で PostgreSQL を立ち上げ、SQL の基礎から PL/pgSQL の実践までを段階的に学ぶ練習環境です。

プロジェクト管理システム（部署・従業員・プロジェクト・タスク・ジョブ）を題材に、実際のテーブルとサンプルデータを使って手を動かしながら学習します。

## 学習の流れ

| # | セクション | 内容 |
|---|---|---|
| 0 | [セットアップ](docs/0-setup/README.md) | Docker 起動、テーブル作成、シードデータ投入 |
| 1 | [データベース定義](docs/1-database/README.md) | ER 図、テーブル定義、サンプルデータの確認 |
| 2 | [SQL 基礎](docs/2-basic/README.md) | SELECT / INSERT / UPDATE / DELETE の基本操作 |
| 3 | [PL/pgSQL 基本制御](docs/3-basic-control/README.md) | 変数、条件分岐、ループ、カーソル、例外処理 |
| 4 | [PostgreSQL 固有機能](docs/4-advanced-control/README.md) | PERFORM、動的 SQL、配列/JSON、CTE、関数/トリガー |
| 5 | [実践課題](docs/5-practice/README.md) | 学んだ知識を組み合わせた総合課題 (6 題 + 発展課題) |

各セクションは前のセクションで学んだ構文だけを使って書かれているため、上から順に進めてください。

## クイックスタート

```bash
# 1. 環境変数ファイルを作成
bash scripts/setup-env.sh -y

# 2. PostgreSQL を起動
docker compose up -d

# 3. テーブル作成 & シードデータ投入
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/0-setup/sql/0-definition.sql \
  -f docs/0-setup/sql/1-seeds.sql
```

詳しい手順は [セットアップ](docs/0-setup/README.md) を参照してください。

## 前提ツール

- **Docker** — [macOS](https://docs.docker.com/desktop/setup/install/mac-install/) / [Windows](https://docs.docker.com/desktop/setup/install/windows-install/) / Linux (`apt-get install docker.io docker-compose-plugin`)
- **psql** — macOS: `brew install libpq` / Linux: `apt-get install postgresql-client`

## ドキュメント

[docs/README.md](docs/README.md) — 全体の目次とディレクトリ構成
