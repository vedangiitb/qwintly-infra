-- ============================================================
-- Migration: update_get_generation_summary_tokens
-- ============================================================

-- Drop the existing function first (since we are modifying the output table signature)
drop function if exists public.get_generation_summary(uuid);

-- Recreate function with input_tokens, output_tokens, input_cost, and output_cost
create or replace function public.get_generation_summary(
    p_msg_id uuid
)
returns table (
    messages text[],
    "genStatus" public.task_status,
    id uuid,
    session_type public.session_type,
    input_tokens bigint,
    output_tokens bigint,
    input_cost numeric,
    output_cost numeric
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
        gs.status as "genStatus",
        gs.id as id,
        gs.session_type as session_type,
        coalesce(
            (select sum(gt.input_tokens) from public.gen_tokens_consumed gt where gt.gen_id = gs.id),
            0
        )::bigint as input_tokens,
        coalesce(
            (select sum(gt.output_tokens) from public.gen_tokens_consumed gt where gt.gen_id = gs.id),
            0
        )::bigint as output_tokens,
        coalesce(
            (select sum(gt.input_cost) from public.gen_tokens_consumed gt where gt.gen_id = gs.id),
            0.00
        )::numeric as input_cost,
        coalesce(
            (select sum(gt.output_cost) from public.gen_tokens_consumed gt where gt.gen_id = gs.id),
            0.00
        )::numeric as output_cost
    from public.generation_sessions gs
    left join public.generation_events ge
      on ge.gen_id = gs.id
     and ge.conv_id = gs.conv_id
     and ge.displayed_summary is true
    where gs.message_id = p_msg_id
    group by gs.status, gs.id, gs.session_type;
$$;

-- Grant execution permissions
grant execute on function public.get_generation_summary(uuid) to authenticated;
grant execute on function public.get_generation_summary(uuid) to service_role;
