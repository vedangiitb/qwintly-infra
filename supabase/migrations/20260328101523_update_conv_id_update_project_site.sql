create or replace function public.update_project_site(
  p_conv_id uuid,
  p_url text,
  p_cloudrun_url text
)
returns text
language plpgsql
as $$
declare
  v_url text;
begin
  insert into public.project_sites (conv_id, url, cloudrun_url, version)
  values (p_conv_id, p_url, p_cloudrun_url, 1)
  on conflict (conv_id) do update
  set
    url = case when public.project_sites.url is null then excluded.url else public.project_sites.url end,
    cloudrun_url = case when public.project_sites.cloudrun_url is null then excluded.cloudrun_url else public.project_sites.cloudrun_url end,
    version = case
      when public.project_sites.url is null and public.project_sites.cloudrun_url is null then 1
      else coalesce(public.project_sites.version, 0) + 1
    end
  returning public.project_sites.url into v_url;

  return v_url;
end;
$$;
