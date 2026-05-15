-- =========================
-- TABLE: project_sites
-- Add gen_id (nullable FK -> generation_sessions.id)
-- =========================

alter table public.project_sites
  add column if not exists gen_id uuid references public.generation_sessions (id) on delete cascade;

-- =========================
-- RPC: update_project_site
-- Add p_gen_id to set project_sites.gen_id
-- =========================
create or replace function public.update_project_site(
  p_conv_id uuid,
  p_url text,
  p_cloudrun_url text,
  p_gen_id uuid
)
returns text
language plpgsql
as $$
declare
  v_url text;
begin
  insert into public.project_sites (conv_id, url, cloudrun_url, version, gen_id)
  values (p_conv_id, p_url, p_cloudrun_url, 1, p_gen_id)
  on conflict (conv_id) do update
  set
    url = case when public.project_sites.url is null then excluded.url else public.project_sites.url end,
    cloudrun_url = case when public.project_sites.cloudrun_url is null then excluded.cloudrun_url else public.project_sites.cloudrun_url end,
    gen_id = coalesce(excluded.gen_id, public.project_sites.gen_id),
    version = case
      when public.project_sites.url is null and public.project_sites.cloudrun_url is null then 1
      else coalesce(public.project_sites.version, 0) + 1
    end
  returning public.project_sites.url into v_url;

  return v_url;
end;
$$;

