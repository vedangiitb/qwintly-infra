-- =========================
-- RLS: generation_pages
-- Public read access
-- =========================

alter table public.generation_pages enable row level security;

create policy "Public can read generation pages" on public.generation_pages for
select
    to public using (true);

