-- ============================================================
-- RPC: fetch_recent_context
-- Purpose:
-- Fetch last 3 user messages and last 2 model messages
-- (if they exist) along with related tool call summary.
-- Ordered chronologically for AI context consumption.
-- ============================================================

drop function if exists public.fetch_recent_context(uuid);

create or replace function public.fetch_recent_context(p_conv_id uuid)
returns table (
    id uuid,
    role public.roles,
    content text,
    msg_type public.msg_type,
    tool_name text,
    tool_summary text,
    tool_status public.tool_call_status
)
language sql
stable
as $$
    with last_users as (
        select *
        from public.messages
        where conv_id = p_conv_id
          and role = 'user'
        order by created_at desc
        limit 3
    ),
    last_ai as (
        select *
        from public.messages
        where conv_id = p_conv_id
          and role = 'model'
        order by created_at desc
        limit 2
    ),
    combined as (
        select * from last_users
        union all
        select * from last_ai
    )
    select 
        m.id,
        m.role,
        m.content,
        m.msg_type,
        tc.tool_name,
        tc.summary as tool_summary,
        tc.status as tool_status
    from combined m
    left join public.chat_tool_calls tc
        on tc.message_id = m.id
    order by m.created_at asc;
$$;
