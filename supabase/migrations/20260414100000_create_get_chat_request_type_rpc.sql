-- ============================================================
-- RPC: get_chat_request_type
-- Purpose:
-- - Verify the provided chat belongs to the provided user (public.chats.user_id)
-- - Return whether the request is "new" or "resume" based on whether a
--   project site (public.project_sites) exists for the chat.
-- ============================================================

create or replace function public.get_chat_request_type(
    p_user_id uuid,
    p_chat_id uuid
)
returns table (request_type text)
language plpgsql
as $$
declare
    v_chat_user_id uuid;
    v_has_site boolean;
begin
    select c.user_id
      into v_chat_user_id
      from public.chats c
     where c.id = p_chat_id;

    if not found then
        raise exception 'Chat not found';
    end if;

    if v_chat_user_id is distinct from p_user_id then
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

