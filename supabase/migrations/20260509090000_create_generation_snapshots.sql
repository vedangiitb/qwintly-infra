-- =========================
-- TABLE: generation_snapshots
-- =========================
create table
    public.generation_snapshots (
        -- 1:1 with generation_sessions
        id uuid primary key references public.generation_sessions (id) on delete cascade,
        created_at timestamptz not null default now (),
        page_config jsonb not null,
        config_size integer not null
    );

-- Enable RLS (service role bypasses; no write policies on purpose)
alter table public.generation_snapshots enable row level security;

-- Public read access (including unauthenticated/anon)
create policy "Public can read generation snapshots" on public.generation_snapshots for
select
    to public using (true);
