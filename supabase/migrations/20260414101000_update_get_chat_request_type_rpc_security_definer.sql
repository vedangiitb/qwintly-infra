-- ============================================================
-- Update: get_chat_request_type (security definer)
-- Purpose:
-- - Make the RPC work even when RLS would hide chats/project_sites rows
-- - Prevent callers from passing an arbitrary p_user_id (impersonation)
-- ============================================================

create or replace function public.get_chat_request_type(
    p_user_id uuid,
    p_chat_id uuid
)
returns table (request_type text)
language plpgsql
security definer
set search_path = public
as $$
declare
    v_has_site boolean;
begin
    -- If this is called from a normal authenticated session, require that
    -- p_user_id matches the caller. (Service-role calls may have auth.uid() = null.)
    if auth.role() <> 'service_role' and auth.uid() is distinct from p_user_id then
        raise exception using
            errcode = '42501',
            message = 'Unauthorized: user id mismatch';
    end if;

    perform 1
      from public.chats c
     where c.id = p_chat_id
       and c.user_id = p_user_id;

    if not found then
        raise exception using
            errcode = '42501',
            message = 'Unauthorized: chat does not belong to user';
    end if;

    select exists (
        select 1
          from public.project_sites ps
         where ps.conv_id = p_chat_id
           and ps.url is not null
    )
    into v_has_site;

    return query
    select case when v_has_site then 'resume' else 'new' end;
end;
$$;

