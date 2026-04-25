-- ============================================================
-- Change: project_context table + RPC
-- - Drop deprecated column: project_context.project_context
-- ============================================================

alter table public.project_context
    drop column if exists project_context;