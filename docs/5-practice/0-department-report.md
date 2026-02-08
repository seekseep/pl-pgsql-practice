# 課題 0: 部署別レポート

難易度: ★☆☆

## 目標

指定した部署の従業員数、参加プロジェクト数、未完了タスク数、期限切れタスク数などの詳細情報を集計し、`RAISE NOTICE` でレポートとして出力する関数を作成する。

## 要件

1. 部署 ID を引数として受け取り、該当部署の詳細レポートを出力する
2. 指定された部署が存在しない場合は `RAISE NOTICE` でメッセージを表示して処理を終了する
3. 従業員数（全体・在籍中）を集計する
4. 部署のメンバーが参加しているプロジェクト数を重複なしで集計する
5. 未完了タスク数（ステータスが `done` 以外）を集計する
6. 期限切れタスク数（未完了かつ `due_date` が過去日）を集計する
7. 集計結果を `RAISE NOTICE` で整形して出力する

## 使用する知識

- `SELECT INTO` による変数への値の格納
- `IF` / `IF NOT FOUND` による条件分岐
- `FOUND` 特殊変数によるクエリ結果の判定
- `RAISE NOTICE` によるメッセージ出力
- `COUNT(*) FILTER (WHERE ...)` による条件付き集計
- `COUNT(DISTINCT ...)` による重複排除カウント

## 解答例

**ファイル:** `sql/0-department-report/0-department-report.sql`

```sql
-- ============================================================
-- 課題 0: 部署別レポート
-- ============================================================
-- 指定した部署の詳細レポートを出力する関数
-- 学習ポイント: SELECT INTO, IF, FOUND, RAISE NOTICE

CREATE OR REPLACE FUNCTION report_department(p_dept_id INT)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_dept_name     VARCHAR;
    v_total_emp     INT;
    v_active_emp    INT;
    v_project_count INT;
    v_open_tasks    INT;
    v_overdue_tasks INT;
BEGIN
    -- 部署の存在チェック
    SELECT name INTO v_dept_name
    FROM departments
    WHERE id = p_dept_id;

    IF NOT FOUND THEN
        RAISE NOTICE '部署ID=% は存在しません', p_dept_id;
        RETURN;
    END IF;

    -- 従業員数
    SELECT
        COUNT(*),
        COUNT(*) FILTER (WHERE is_active = TRUE)
    INTO v_total_emp, v_active_emp
    FROM employees
    WHERE department_id = p_dept_id;

    -- 参加プロジェクト数
    SELECT COUNT(DISTINCT pm.project_id) INTO v_project_count
    FROM project_members pm
    INNER JOIN employees e ON pm.employee_id = e.id
    WHERE e.department_id = p_dept_id;

    -- 未完了タスク数
    SELECT COUNT(*) INTO v_open_tasks
    FROM tasks t
    INNER JOIN employees e ON t.assignee_id = e.id
    WHERE e.department_id = p_dept_id
      AND t.status != 'done';

    -- 期限切れタスク数
    SELECT COUNT(*) INTO v_overdue_tasks
    FROM tasks t
    INNER JOIN employees e ON t.assignee_id = e.id
    WHERE e.department_id = p_dept_id
      AND t.status != 'done'
      AND t.due_date < CURRENT_DATE;

    -- レポート出力
    RAISE NOTICE '========================================';
    RAISE NOTICE '部署レポート: %', v_dept_name;
    RAISE NOTICE '========================================';
    RAISE NOTICE '従業員数: % 人 (在籍: % 人)', v_total_emp, v_active_emp;
    RAISE NOTICE '参加プロジェクト数: %', v_project_count;
    RAISE NOTICE '未完了タスク数: %', v_open_tasks;
    RAISE NOTICE '期限切れタスク数: %', v_overdue_tasks;
END;
$$;

-- 実行テスト
SELECT report_department(1);
SELECT report_department(2);
SELECT report_department(9999);

-- クリーンアップ
DROP FUNCTION IF EXISTS report_department(INT);
```

## 実行方法

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/5-practice/sql/0-department-report/0-department-report.sql
```

---

[PRACTICE](README.md) | [次へ](1-project-dashboard.md) →
