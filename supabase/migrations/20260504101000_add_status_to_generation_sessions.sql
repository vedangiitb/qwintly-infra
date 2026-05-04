-- =========================
-- TABLE: generation_sessions
-- Add status column (task_status enum)
-- Existing rows are backfilled to 'pending' via DEFAULT + NOT NULL.
-- =========================

alter table public.generation_sessions
  add column if not exists status public.task_status not null default 'pending';

