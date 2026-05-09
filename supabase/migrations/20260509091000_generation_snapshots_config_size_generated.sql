-- =========================
-- generation_snapshots: make config_size a generated column
-- (use ALTER since initial migration already applied in dev)
-- =========================

alter table public.generation_snapshots
    drop column if exists config_size;

alter table public.generation_snapshots
    add column config_size integer generated always as (pg_column_size (page_config)) stored;

