-- ============================================================
-- プロジェクト管理システム テーブル定義
-- ============================================================

-- ----------------------------------------------------------
-- departments (部署)
-- ----------------------------------------------------------
CREATE TABLE departments (
    id         SERIAL       PRIMARY KEY,
    name       VARCHAR(100) NOT NULL,
    created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE  departments             IS '部署';
COMMENT ON COLUMN departments.id          IS '部署ID';
COMMENT ON COLUMN departments.name        IS '部署名';
COMMENT ON COLUMN departments.created_at  IS '作成日時';
COMMENT ON COLUMN departments.updated_at  IS '更新日時';

-- ----------------------------------------------------------
-- employees (従業員)
-- ----------------------------------------------------------
CREATE TABLE employees (
    id            SERIAL       PRIMARY KEY,
    department_id INT          NOT NULL REFERENCES departments(id),
    last_name     VARCHAR(50)  NOT NULL,
    first_name    VARCHAR(50)  NOT NULL,
    email         VARCHAR(255) NOT NULL UNIQUE,
    hire_date     DATE         NOT NULL,
    is_active     BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE  employees               IS '従業員';
COMMENT ON COLUMN employees.id            IS '従業員ID';
COMMENT ON COLUMN employees.department_id IS '所属部署ID';
COMMENT ON COLUMN employees.last_name     IS '姓';
COMMENT ON COLUMN employees.first_name    IS '名';
COMMENT ON COLUMN employees.email         IS 'メールアドレス';
COMMENT ON COLUMN employees.hire_date     IS '入社日';
COMMENT ON COLUMN employees.is_active     IS '在籍フラグ';
COMMENT ON COLUMN employees.created_at    IS '作成日時';
COMMENT ON COLUMN employees.updated_at    IS '更新日時';

-- ----------------------------------------------------------
-- projects (プロジェクト)
-- ----------------------------------------------------------
CREATE TABLE projects (
    id          SERIAL       PRIMARY KEY,
    name        VARCHAR(200) NOT NULL,
    description TEXT,
    status      VARCHAR(20)  NOT NULL DEFAULT 'planning',
    start_date  DATE,
    end_date    DATE,
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE  projects             IS 'プロジェクト';
COMMENT ON COLUMN projects.id          IS 'プロジェクトID';
COMMENT ON COLUMN projects.name        IS 'プロジェクト名';
COMMENT ON COLUMN projects.description IS '概要';
COMMENT ON COLUMN projects.status      IS 'ステータス (planning/active/completed/archived)';
COMMENT ON COLUMN projects.start_date  IS '開始日';
COMMENT ON COLUMN projects.end_date    IS '終了日';
COMMENT ON COLUMN projects.created_at  IS '作成日時';
COMMENT ON COLUMN projects.updated_at  IS '更新日時';

-- ----------------------------------------------------------
-- project_members (プロジェクトメンバー / 多対多の中間テーブル)
-- ----------------------------------------------------------
CREATE TABLE project_members (
    id          SERIAL      PRIMARY KEY,
    project_id  INT         NOT NULL REFERENCES projects(id),
    employee_id INT         NOT NULL REFERENCES employees(id),
    role        VARCHAR(20) NOT NULL DEFAULT 'member',
    joined_at   DATE        NOT NULL DEFAULT CURRENT_DATE,
    created_at  TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (project_id, employee_id)
);

COMMENT ON TABLE  project_members             IS 'プロジェクトメンバー (多対多の中間テーブル)';
COMMENT ON COLUMN project_members.id          IS 'プロジェクトメンバーID';
COMMENT ON COLUMN project_members.project_id  IS 'プロジェクトID';
COMMENT ON COLUMN project_members.employee_id IS '従業員ID';
COMMENT ON COLUMN project_members.role        IS '役割 (manager/member/reviewer)';
COMMENT ON COLUMN project_members.joined_at   IS '参加日';
COMMENT ON COLUMN project_members.created_at  IS '作成日時';
COMMENT ON COLUMN project_members.updated_at  IS '更新日時';

-- ----------------------------------------------------------
-- tasks (タスク)
-- ----------------------------------------------------------
CREATE TABLE tasks (
    id          SERIAL       PRIMARY KEY,
    project_id  INT          NOT NULL REFERENCES projects(id),
    assignee_id INT          REFERENCES employees(id),
    title       VARCHAR(300) NOT NULL,
    description TEXT,
    status      VARCHAR(20)  NOT NULL DEFAULT 'todo',
    priority    VARCHAR(10)  NOT NULL DEFAULT 'medium',
    due_date    DATE,
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE  tasks             IS 'タスク';
COMMENT ON COLUMN tasks.id          IS 'タスクID';
COMMENT ON COLUMN tasks.project_id  IS 'プロジェクトID';
COMMENT ON COLUMN tasks.assignee_id IS '担当者ID (従業員ID)';
COMMENT ON COLUMN tasks.title       IS 'タイトル';
COMMENT ON COLUMN tasks.description IS '詳細';
COMMENT ON COLUMN tasks.status      IS 'ステータス (todo/in_progress/in_review/done)';
COMMENT ON COLUMN tasks.priority    IS '優先度 (low/medium/high/urgent)';
COMMENT ON COLUMN tasks.due_date    IS '期限日';
COMMENT ON COLUMN tasks.created_at  IS '作成日時';
COMMENT ON COLUMN tasks.updated_at  IS '更新日時';

-- ----------------------------------------------------------
-- jobs (ジョブ)
-- ----------------------------------------------------------
CREATE TABLE jobs (
    id          SERIAL       PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    description TEXT,
    job_type    VARCHAR(30)  NOT NULL,
    schedule    VARCHAR(100),
    is_enabled  BOOLEAN      NOT NULL DEFAULT TRUE,
    last_run_at TIMESTAMP,
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE  jobs             IS 'ジョブ定義';
COMMENT ON COLUMN jobs.id          IS 'ジョブID';
COMMENT ON COLUMN jobs.name        IS 'ジョブ名';
COMMENT ON COLUMN jobs.description IS 'ジョブの説明';
COMMENT ON COLUMN jobs.job_type    IS '種別 (daily_report/data_sync/cleanup)';
COMMENT ON COLUMN jobs.schedule    IS 'スケジュール (cron式 例: 0 9 * * *)';
COMMENT ON COLUMN jobs.is_enabled  IS '有効フラグ';
COMMENT ON COLUMN jobs.last_run_at IS '最終実行日時';
COMMENT ON COLUMN jobs.created_at  IS '作成日時';
COMMENT ON COLUMN jobs.updated_at  IS '更新日時';

-- ----------------------------------------------------------
-- job_logs (ジョブ実行ログ)
-- ----------------------------------------------------------
CREATE TABLE job_logs (
    id          SERIAL      PRIMARY KEY,
    job_id      INT         NOT NULL REFERENCES jobs(id),
    status      VARCHAR(20) NOT NULL,
    started_at  TIMESTAMP   NOT NULL,
    finished_at TIMESTAMP,
    message     TEXT,
    created_at  TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE  job_logs             IS 'ジョブ実行ログ';
COMMENT ON COLUMN job_logs.id          IS 'ジョブログID';
COMMENT ON COLUMN job_logs.job_id      IS 'ジョブID';
COMMENT ON COLUMN job_logs.status      IS '結果 (running/success/failure)';
COMMENT ON COLUMN job_logs.started_at  IS '開始日時';
COMMENT ON COLUMN job_logs.finished_at IS '終了日時';
COMMENT ON COLUMN job_logs.message     IS '実行メッセージ / エラー内容';
COMMENT ON COLUMN job_logs.created_at  IS '作成日時';
