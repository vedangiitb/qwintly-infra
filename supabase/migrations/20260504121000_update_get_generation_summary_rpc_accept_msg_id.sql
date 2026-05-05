-- ============================================================
-- RPC: get_generation_summary
-- Update:
-- - Accept only p_msg_id (messages.id)
-- - Resolve (conv_id, gen_id) via generation_sessions.message_id
-- - Fetch same generation_events rows as before
-- ============================================================

drop function if exists public.get_generation_summary(uuid, uuid);

create or replace function public.get_generation_summary(
    p_msg_id uuid
)
returns table (
    messages text[],
    "genStatus" public.task_status
)
language sql
stable
set search_path = public
as $$
    select
        coalesce(
            array_agg(ge.message order by ge.seq_num) filter (where ge.message is not null),
            '{}'::text[]
        ) as messages,
        gs.status as "genStatus"
    from public.generation_sessions gs
    left join public.generation_events ge
      on ge.gen_id = gs.id
     and ge.conv_id = gs.conv_id
     and ge.displayed_summary is true
    where gs.message_id = p_msg_id
    group by gs.status;
$$;
