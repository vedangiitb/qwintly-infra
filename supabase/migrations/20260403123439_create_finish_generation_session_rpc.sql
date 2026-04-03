-- ============================================================
-- RPC: finish_generation_session
-- Purpose:
-- Atomically finish a generation session by:
-- 1) locking the chat row
-- 2) ensuring it is currently generating
-- 3) ensuring the generation session exists
-- 4) setting is_generating = false
-- 5) updating generation_sessions.step = completed
-- ============================================================

create or replace function public.finish_generation_session(
    p_conv_id uuid,
    p_gen_id uuid
)
returns void
language plpgsql
as $$
declare
    v_is_generating boolean;
    v_exists boolean;
begin
    -- Lock the chat row to prevent concurrent updates
    select c.is_generating
      into v_is_generating
      from public.chats c
     where c.id = p_conv_id
     for update;

    if not found then
        raise exception 'Chat not found';
    end if;

    if not v_is_generating then
        raise exception 'Chat is not generating';
    end if;

    select true
      into v_exists
      from public.generation_sessions gs
     where gs.id = p_gen_id
       and gs.conv_id = p_conv_id
     limit 1;

    if not found then
        raise exception 'Generation session not found';
    end if;

    update public.chats
       set is_generating = false
     where id = p_conv_id;

    update public.generation_sessions
       set step = 'completed',
           last_modified = now()
     where id = p_gen_id
       and conv_id = p_conv_id;
end;
$$;
