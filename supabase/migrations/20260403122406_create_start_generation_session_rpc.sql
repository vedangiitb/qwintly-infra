-- ============================================================
-- RPC: start_generation_session
-- Purpose:
-- Atomically start a generation session by:
-- 1) locking the chat row
-- 2) ensuring it is not already generating
-- 3) setting is_generating = true
-- 4) inserting a generation_sessions row with step = initiating
-- Returns: new generation_sessions.id
-- ============================================================

create or replace function public.start_generation_session(p_conv_id uuid)
returns uuid
language plpgsql
as $$
declare
    v_is_generating boolean;
    v_gen_id uuid;
begin
    -- Lock the chat row to prevent concurrent starts
    select c.is_generating
      into v_is_generating
      from public.chats c
     where c.id = p_conv_id
     for update;

    if not found then
        raise exception 'Chat not found';
    end if;

    if v_is_generating then
        raise exception 'Chat is already generating';
    end if;

    update public.chats
       set is_generating = true
     where id = p_conv_id;

    insert into public.generation_sessions (conv_id, step)
    values (p_conv_id, 'initiating')
    returning id into v_gen_id;

    return v_gen_id;
end;
$$;
