-- =========================
-- TABLE: generation_sessions
-- =========================
create table
    public.generation_sessions (
        id uuid primary key default gen_random_uuid (),
        conv_id uuid not null references public.chats (id) on delete cascade,
        step gen_step not null,
        created_at timestamptz not null default now (),
        last_modified timestamptz not null default now ()
    );

create index idx_generation_sessions_conv_id_created_at on public.generation_sessions (conv_id, created_at desc);

alter table public.generation_sessions enable row level security;

-- =========================
-- TABLE: generation_events updates
-- =========================
alter table public.generation_events
  add column gen_id uuid
  references public.generation_sessions (id) on delete cascade;

drop index if exists public.uq_generation_events_conv_seq;

create unique index uq_generation_events_gen_seq on public.generation_events (gen_id, seq_num);

create index idx_generation_events_gen_id_created_at on public.generation_events (gen_id, created_at);
