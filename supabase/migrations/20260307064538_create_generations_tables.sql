-- =========================
-- TABLE: generation_events table
-- =========================
create table
    public.generation_events (
        id uuid primary key default gen_random_uuid (),
        conv_id uuid not null references public.chats (id) on delete cascade,
        event_type event_type not null,
        step gen_step,
        message text,
        source text,
        created_at timestamptz not null default now (),
        last_modified timestamptz not null default now (),
        seq_num integer not null,
        metadata jsonb
    );

-- Ensure strict ordering per conversation
create unique index uq_generation_events_conv_seq on public.generation_events (conv_id, seq_num);

-- Fast history lookup
create index idx_generation_events_conv_id_created_at on public.generation_events (conv_id, created_at);

-- Faster latest-event query
create index idx_generation_events_conv_seq_desc on public.generation_events (conv_id, seq_num desc);

-- Enable RLS
alter table public.generation_events enable row level security;
