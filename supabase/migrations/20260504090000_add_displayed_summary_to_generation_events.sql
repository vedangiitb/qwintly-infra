-- =========================
-- TABLE: generation_events
-- Add displayed_summary flag (defaults to false)
-- Existing rows are backfilled to false via DEFAULT + NOT NULL.
-- =========================

alter table public.generation_events
  add column if not exists displayed_summary boolean not null default false;

