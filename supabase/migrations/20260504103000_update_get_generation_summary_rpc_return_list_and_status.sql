-- ============================================================
-- Update: get_generation_summary
-- Purpose:
-- - Return summary messages as a list (text[])
-- - Include generation session status as genStatus (task_status)
-- ============================================================

create or replace function public.get_generation_summary(
    p_chat_id uuid,
    p_gen_id uuid
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
    where gs.conv_id = p_chat_id
      and gs.id = p_gen_id
    group by gs.status;
$$;

