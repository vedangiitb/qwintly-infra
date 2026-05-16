-- =========================
-- TABLE: gen_tool_calls
-- =========================
create table
  public.gen_tool_calls (
    id uuid primary key default gen_random_uuid (),
    gen_id uuid not null references public.generation_sessions (id) on delete cascade,
    tool_call_name text not null,
    tool_params jsonb,
    tool_final_output jsonb
  );

create index idx_gen_tool_calls_gen_id on public.gen_tool_calls (gen_id);

alter table public.gen_tool_calls enable row level security;
