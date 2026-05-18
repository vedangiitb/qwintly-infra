-- =========================
-- ENUM: op_status
-- =========================
create type public.op_status as enum ('queued', 'applied',);
-- =========================
-- TABLE: project_operations
-- =========================
create table
  public.project_operations (
    id uuid primary key default gen_random_uuid (),
    gen_id uuid not null references public.generation_sessions (id) on delete cascade,
    route text not null,
    status public.op_status not null default 'queued',
    created_at timestamptz not null default now (),
    operation jsonb not null
  );

create index project_operations_gen_id_idx on public.project_operations (gen_id);

create index project_operations_gen_route_created_idx on public.project_operations (gen_id, route, created_at desc);

create index project_operations_gen_route_status_idx on public.project_operations (gen_id, route, status);

-- =========================
-- ENABLE RLS
-- =========================
alter table public.project_operations enable row level security;

-- =========================
-- SELECT
-- =========================
create policy "Users can view their project operations"
on public.project_operations
for select
using (
  exists (
    select 1
    from public.generation_sessions gs
    join public.chats c
      on c.id = gs.conv_id
    where gs.id = project_operations.gen_id
      and c.user_id = auth.uid()
  )
);

-- =========================
-- INSERT
-- =========================
create policy "Users can insert their project operations"
on public.project_operations
for insert
with check (
  exists (
    select 1
    from public.generation_sessions gs
    join public.chats c
      on c.id = gs.conv_id
    where gs.id = project_operations.gen_id
      and c.user_id = auth.uid()
  )
);

-- =========================
-- UPDATE
-- =========================
create policy "Users can update their project operations"
on public.project_operations
for update
using (
  exists (
    select 1
    from public.generation_sessions gs
    join public.chats c
      on c.id = gs.conv_id
    where gs.id = project_operations.gen_id
      and c.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1
    from public.generation_sessions gs
    join public.chats c
      on c.id = gs.conv_id
    where gs.id = project_operations.gen_id
      and c.user_id = auth.uid()
  )
);

-- =========================
-- DELETE (optional)
-- =========================
create policy "Users can delete their project operations"
on public.project_operations
for delete
using (
  exists (
    select 1
    from public.generation_sessions gs
    join public.chats c
      on c.id = gs.conv_id
    where gs.id = project_operations.gen_id
      and c.user_id = auth.uid()
  )
);