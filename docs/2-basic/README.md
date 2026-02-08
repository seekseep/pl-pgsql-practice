# SQL 基礎

基本的な CRUD 操作 (SELECT / INSERT / UPDATE / DELETE) を学びます。
全て DATABASE.md に定義されたテーブルを使用します。

---

## 目次

| # | トピック | ファイル数 | 説明 |
|---|---|---|---|
| 0 | [SELECT](0-select.md) | 21 | 全件取得, WHERE, JOIN, GROUP BY, サブクエリ, CASE |
| 1 | [INSERT](1-insert.md) | 7 | 単一行, 複数行, RETURNING, UPSERT |
| 2 | [UPDATE](2-update.md) | 8 | 条件付き, CASE, FROM 句, RETURNING |
| 3 | [DELETE](3-delete.md) | 8 | 条件付き, EXISTS, USING, TRUNCATE |

## 実行方法

```bash
source .env

# セクションをまとめて実行
for f in docs/2-basic/sql/0-select/*.sql; do
  psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f "$f"
done
```

## 注意事項

- INSERT / UPDATE / DELETE を実行するとデータが変更されます
- やり直す場合は `docker compose down -v && docker compose up -d` でリセットし、セットアップを再実行してください
- 詳しくは [SETUP.md](../0-setup/README.md) を参照してください

---

[次へ: PL/pgSQL 基本制御 →](../3-basic-control/README.md)
