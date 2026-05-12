-- =========================
-- DROP: generation_pages
-- =========================

drop index if exists public.idx_generation_pages_generation_id;
drop table if exists public.generation_pages cascade;

