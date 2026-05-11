-- ============================================================
-- Update: generation_sessions.session_type + RPC updates
--
-- Changes:
-- - Create public.session_type enum ('deploy', 'generate')
-- - Add generation_sessions.session_type (NOT NULL, default 'generate')
-- - start_generation_session(): require p_session_type and persist it
-- - get_generation_summary(): return generation_sessions.id + session_type
-- ============================================================

do $$
begin
    if not exists (
        select
            1
        from
            pg_type t
            join pg_namespace n on n.oid = t.typnamespace
        where
            n.nspname = 'public'
            and t.typname = 'session_type'
    ) then
        create type public.session_type as enum ('deploy', 'generate');
    end if;
end;
$$;

alter table public.generation_sessions
    add column if not exists session_type public.session_type not null default 'generate';

-- Update start_generation_session signature to require p_session_type
drop function if exists public.start_generation_session(uuid, uuid);

create or replace function public.start_generation_session(
    p_conv_id uuid,
    p_plan_id uuid,
    p_session_type public.session_type
)
returns uuid
language plpgsql
as $$
declare
    v_is_generating boolean;
    v_gen_id uuid;
    v_task_status text;
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

    -- Lock the task row as well to prevent concurrent starts for the same plan/task
    select pt.status::text
      into v_task_status
      from public.project_tasks pt
     where pt.id = p_plan_id
       and pt.conv_id = p_conv_id
     for update;

    if not found then
        raise exception 'Task not found';
    end if;

    if v_task_status not in ('pending', 'updated', 'failed') then
        raise exception 'Task is not startable (status=%)', v_task_status;
    end if;

    update public.chats
       set is_generating = true
     where id = p_conv_id;

    -- Mark only the selected plan/task as "implementing"
    -- NOTE: dynamic SQL avoids referencing newly-added enum labels in the same migration transaction.
    execute
        'update public.project_tasks
            set status = ''implementing''
          where id = $1
            and conv_id = $2'
        using p_plan_id, p_conv_id;

    insert into public.generation_sessions (conv_id, plan_id, step, session_type)
    values (p_conv_id, p_plan_id, 'initiating', p_session_type)
    returning id into v_gen_id;

    return v_gen_id;
end;
$$;

-- Update get_generation_summary to return generation_sessions.id + session_type
drop function if exists public.get_generation_summary(uuid);

create or replace function public.get_generation_summary(
    p_msg_id uuid
)
returns table (
    messages text[],
    "genStatus" public.task_status,
    id uuid,
    session_type public.session_type
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
        gs.session_type as session_type
    from public.generation_sessions gs
    left join public.generation_events ge
      on ge.gen_id = gs.id
     and ge.conv_id = gs.conv_id
     and ge.displayed_summary is true
    where gs.message_id = p_msg_id
    group by gs.status, gs.id, gs.session_type;
$$;

