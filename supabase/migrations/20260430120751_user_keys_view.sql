create view
    public.user_api_keys_safe
with
    (security_invoker = true) as
select
    id,
    user_id,
    provider,
    created_at,
    updated_at,
    key_version
from
    public.user_api_keys;

grant select on public.user_api_keys_safe to authenticated;
