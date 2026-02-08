# SQL 基礎

基本的な CRUD 操作 (SELECT / INSERT / UPDATE / DELETE) を学びます。
全て DATABASE.md に定義されたテーブルを使用します。

---

## 目次

| # | トピック | ファイル数 | 説明 |
|---|---|---|---|
| 1 | [SELECT 基礎](1-basic-select.md) | 14 | 全件取得, WHERE, COALESCE, ORDER BY, GROUP BY, HAVING |
| 2 | [SELECT 応用](2-advanced-select.md) | 11 | JOIN, サブクエリ, EXISTS, CTE, CASE |
| 3 | [INSERT](3-insert.md) | 7 | 単一行, 複数行, RETURNING, UPSERT |
| 4 | [UPDATE](4-update.md) | 8 | 条件付き, CASE, FROM 句, RETURNING |
| 5 | [DELETE](5-delete.md) | 8 | 条件付き, EXISTS, USING, TRUNCATE |

## 注意事項

- INSERT / UPDATE / DELETE を実行するとデータが変更されます
- やり直す場合は `docker compose down -v && docker compose up -d` でリセットし、セットアップを再実行してください
- 詳しくは [SETUP.md](../1-setup/README.md) を参照してください

---

[次へ: PL/pgSQL 基本制御 →](../4-basic-control/README.md)
