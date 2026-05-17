-- =========================
-- TABLE: gen_tool_calls
-- COLUMN: created_at
-- =========================

alter table public.gen_tool_calls
add column created_at timestamptz;

alter table public.gen_tool_calls
alter column created_at set default now();

update public.gen_tool_calls
set created_at = now()
where created_at is null;

alter table public.gen_tool_calls
alter column created_at set not null;

