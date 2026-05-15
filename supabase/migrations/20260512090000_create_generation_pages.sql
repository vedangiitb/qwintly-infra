-- =========================
-- TABLE: generation_pages
-- =========================
create table
    public.generation_pages (
        id uuid primary key default gen_random_uuid (),
        generation_id uuid not null references public.generation_sessions (id) on delete cascade,
        enabled boolean not null default true,
        created_at timestamptz not null default now (),
        updated_at timestamptz not null default now (),
        route text,
        page_config jsonb
    );

create index idx_generation_pages_generation_id on public.generation_pages (generation_id);

-- Auto-update updated_at.
create trigger set_updated_at before
update on public.generation_pages for each row execute procedure update_updated_at_column ();
