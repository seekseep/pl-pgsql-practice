# 課題 5: 月次サマリーレポート

難易度: ★★★

## 目標

指定した年月の活動サマリー（新規入社者数、稼働プロジェクト数、タスクの作成・完了数、ジョブ実行状況、部署別内訳）を JSONB 形式で返す関数を作成する。

## 要件

1. 日付（`DATE` 型）を引数として受け取り、その月のサマリーを JSONB で返す
2. `DATE_TRUNC` を使って月の開始日と終了日を計算する
3. 以下の情報を集計する:
   - 新規入社者数（`hire_date` が対象月内の従業員）
   - 稼働中プロジェクト数（`active` ステータスで対象月に期間が重なるもの）
   - 作成されたタスク数（`created_at` が対象月内）
   - 完了したタスク数（`done` ステータスで `updated_at` が対象月内）
   - ジョブ実行回数（`started_at` が対象月内）
   - ジョブ失敗回数（上記のうち `failure` ステータス）
4. 部署ごとの従業員数（全体・アクティブ）を `jsonb_agg` で配列として構築する
5. 全ての集計結果を `jsonb_build_object` で一つの JSON オブジェクトにまとめて返す

## 使用する知識

- `RETURNS JSONB` による JSON 返却関数の定義
- `jsonb_build_object` による JSON オブジェクトの構築
- `jsonb_agg` による JSON 配列の集約
- `DATE_TRUNC` による月の開始日の計算
- `COALESCE` による NULL の安全な処理
- `TO_CHAR` による日付のフォーマット
- `COUNT(*) FILTER (WHERE ...)` による条件付き集計
- サブクエリを使った複雑な集計

## 解答例

**ファイル:** `sql/5-monthly-summary/0-monthly-summary.sql`

```sql
-- ============================================================
-- 課題 5: 月次サマリーレポート
-- ============================================================
-- 指定した年月の活動サマリーを JSON 形式で返す関数
-- 学習ポイント: RETURNS JSONB, jsonb_build_object, jsonb_agg, DATE_TRUNC

CREATE OR REPLACE FUNCTION get_monthly_summary(p_month DATE)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_start         DATE;
    v_end           DATE;
    v_new_emp       INT;
    v_active_proj   INT;
    v_tasks_created INT;
    v_tasks_done    INT;
    v_job_exec      INT;
    v_job_fail      INT;
    v_dept_breakdown JSONB;
BEGIN
    -- 月の範囲を計算
    v_start := DATE_TRUNC('month', p_month)::DATE;
    v_end   := (v_start + INTERVAL '1 month')::DATE;

    -- 新規入社者数
    SELECT COUNT(*) INTO v_new_emp
    FROM employees
    WHERE hire_date >= v_start AND hire_date < v_end;

    -- 稼働中プロジェクト数
    SELECT COUNT(*) INTO v_active_proj
    FROM projects
    WHERE status = 'active'
      AND (start_date IS NULL OR start_date < v_end)
      AND (end_date IS NULL OR end_date >= v_start);

    -- 作成されたタスク数
    SELECT COUNT(*) INTO v_tasks_created
    FROM tasks
    WHERE created_at >= v_start AND created_at < v_end;

    -- 完了したタスク数
    SELECT COUNT(*) INTO v_tasks_done
    FROM tasks
    WHERE status = 'done'
      AND updated_at >= v_start AND updated_at < v_end;

    -- ジョブ実行回数
    SELECT COUNT(*) INTO v_job_exec
    FROM job_logs
    WHERE started_at >= v_start AND started_at < v_end;

    -- ジョブ失敗回数
    SELECT COUNT(*) INTO v_job_fail
    FROM job_logs
    WHERE started_at >= v_start AND started_at < v_end
      AND status = 'failure';

    -- 部署ごとの従業員数
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'department', sub.name,
            'total',      sub.total,
            'active',     sub.active
        ) ORDER BY sub.name
    ), '[]'::JSONB)
    INTO v_dept_breakdown
    FROM (
        SELECT
            d.name,
            COUNT(e.id) AS total,
            COUNT(e.id) FILTER (WHERE e.is_active = TRUE) AS active
        FROM departments d
        LEFT JOIN employees e ON d.id = e.department_id
        GROUP BY d.id, d.name
    ) sub;

    -- JSON を構築して返す
    RETURN jsonb_build_object(
        'period',               TO_CHAR(v_start, 'YYYY-MM'),
        'new_employees',        v_new_emp,
        'active_projects',      v_active_proj,
        'tasks_created',        v_tasks_created,
        'tasks_completed',      v_tasks_done,
        'job_executions',       v_job_exec,
        'job_failures',         v_job_fail,
        'department_breakdown', v_dept_breakdown
    );
END;
$$;

-- 実行テスト
DO $$
DECLARE
    v_result JSONB;
BEGIN
    v_result := get_monthly_summary('2025-06-01');
    RAISE NOTICE '%', jsonb_pretty(v_result);
END;
$$;

-- クリーンアップ
DROP FUNCTION IF EXISTS get_monthly_summary(DATE);
```

## 実行方法

```bash
source .env
psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -f docs/5-practice/sql/5-monthly-summary/0-monthly-summary.sql
```

---

← [前へ](4-job-executor.md) | [PRACTICE](README.md)
