create view
    public.user_api_keys_safe as
select
    id,
    user_id,
    provider,
    created_at,
    updated_at,
    key_version
from
    public.user_api_keys;

alter view public.user_api_keys_safe enable row level security;

create policy "Users can view their own keys metadata" on public.user_api_keys_safe for
select
    to authenticated using (auth.uid () = user_id);