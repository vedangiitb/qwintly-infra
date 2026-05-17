-- ===========================================
-- RLS: deployment_generation_map
-- - Public read access
-- - Write access restricted to service_role
-- ===========================================

alter table public.deployment_generation_map enable row level security;

drop policy if exists "Public can read deployment generation map" on public.deployment_generation_map;
drop policy if exists "Service role can write deployment generation map" on public.deployment_generation_map;

create policy "Public can read deployment generation map" on public.deployment_generation_map for
select
    to public using (true);

create policy "Service role can write deployment generation map" on public.deployment_generation_map for
all
    to service_role using (true) with check (true);

