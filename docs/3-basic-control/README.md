# PL/pgSQL 基本制御構文

PL/pgSQL の基本的な制御構文を学びます。
各トピックはサブディレクトリに分割されており、1 ファイル = 1 テーマです。
前のトピックで学んだ構文のみを使い、まだ登場していない構文は使いません。

---

## 目次

| # | トピック | ファイル数 | 説明 |
|---|---|---|---|
| 0 | [変数](0-variables.md) | 8 | DECLARE, :=, SELECT INTO, %TYPE, %ROWTYPE, RECORD, FOUND |
| 1 | [条件分岐](1-condition.md) | 8 | IF/ELSIF/ELSE, CASE, NULL チェック |
| 2 | [ループ](2-loop.md) | 9 | LOOP, WHILE, FOR, CONTINUE, EXIT |
| 3 | [カーソル](3-cursor.md) | 6 | CURSOR, FETCH, SCROLL, FOR カーソル |
| 4 | [例外処理](4-exception.md) | 9 | EXCEPTION, RAISE, SQLSTATE, GET DIAGNOSTICS |

## 実行方法

```bash
source .env

# セクションをまとめて実行
for f in docs/3-basic-control/sql/0-variables/*.sql; do
  psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f "$f"
done
```

---

← [SQL 基礎](../2-basic/README.md) | [次へ: PostgreSQL 固有機能 →](../4-advanced-control/README.md)
