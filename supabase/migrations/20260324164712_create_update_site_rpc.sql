create or replace function public.update_project_site(
  p_conv_id text,
  p_url text
)
returns text
language plpgsql
as $$
declare
  v_url text;
  v_row_count integer;
begin
  update public.project_sites
  set
    url = case when url is null then p_url else url end,
    version = case
      when url is null then 1
      else coalesce(version, 0) + 1
    end
  where conv_id = p_conv_id
  returning url into v_url;

  get diagnostics v_row_count = row_count;
  if v_row_count = 0 then
    raise exception 'Project site not found for this conversation.';
  end if;

  return v_url;
end;
$$;
