-- =========================
-- ENUM: roles
-- =========================
create type public.roles as enum ('user', 'model');

-- =========================
-- ENUM: tool_call_status
-- =========================
create type public.tool_call_status as enum ('pending', 'success', 'failed');

-- =========================
-- ENUM: task_status
-- =========================
create type public.task_status as enum ('pending', 'updated', 'implemented');

-- =========================
-- ENUM: msg_type
-- =========================
create type public.msg_type as enum ('message', 'plan', 'questions');

-- =========================
-- ENUM: question_status
-- =========================
create type public.question_status as enum ('pending', 'answered', 'skipped');

-- =========================
-- ENUM: event_type
-- =========================
create type event_type as enum (
  'step_started',
  'step_finished',
  'step_error',
  'step_retry',
  'generation_completed',
  'generation_failed'
);

-- =========================
-- ENUM: gen_step
-- =========================
create type gen_step as enum (
  'initiating',
  'building',
  'deploying'
);
