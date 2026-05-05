-- ============================================================
-- RPC: get_generation_summary
-- Purpose:
-- - Fetch summary messages for a generation (gen_id) within a chat (conv_id)
-- - Only return rows explicitly marked displayed_summary = true
-- Notes:
-- - SECURITY INVOKER (default): relies on RLS on generation_events/chats
-- ============================================================

create or replace function public.get_generation_summary(
    p_chat_id uuid,
    p_gen_id uuid
)
returns table (message text)
language sql
stable
set search_path = public
as $$
    select ge.message
      from public.generation_events ge
     where ge.conv_id = p_chat_id
       and ge.gen_id = p_gen_id
       and ge.displayed_summary is true
       and ge.message is not null
     order by ge.seq_num asc;
$$;

