-- ============================================================
-- Update: task_status enum + generation session RPCs
--
-- Changes:
-- - Add 'implementing' and 'failed' values to public.task_status
-- - Add generation_sessions.plan_id (nullable FK -> project_tasks.id)
-- - start_generation_session(): accept p_plan_id, lock that task, set it to implementing, and store plan_id on the session
-- - finish_generation_session(): accept p_plan_id + p_success and set only that task to implemented/failed accordingly
-- ============================================================

-- Add new enum values (ordered for readability in admin tools)
alter type public.task_status add value if not exists 'implementing' after 'pending';
alter type public.task_status add value if not exists 'failed' after 'implemented';

-- Add nullable plan_id to generation_sessions (older rows will remain NULL)
alter table public.generation_sessions add column if not exists plan_id uuid;

do $$
begin
    if not exists (
        select
            1
        from
            pg_constraint
        where
            conname = 'generation_sessions_plan_id_fkey'
            and conrelid = 'public.generation_sessions'::regclass
    ) then
        alter table public.generation_sessions
            add constraint generation_sessions_plan_id_fkey foreign key (plan_id) references public.project_tasks (id) on delete set null;
    end if;
end;
$$;

create index if not exists idx_generation_sessions_plan_id on public.generation_sessions (plan_id);

-- Update start_generation_session to mark a single task as implementing and tie the session to it
drop function if exists public.start_generation_session(uuid);

create or replace function public.start_generation_session(
    p_conv_id uuid,
    p_plan_id uuid
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

    insert into public.generation_sessions (conv_id, plan_id, step)
    values (p_conv_id, p_plan_id, 'initiating')
    returning id into v_gen_id;

    return v_gen_id;
end;
$$;

-- Replace finish_generation_session with a new signature including p_plan_id + p_success
drop function if exists public.finish_generation_session(uuid, uuid);
drop function if exists public.finish_generation_session(uuid, uuid, boolean);

create or replace function public.finish_generation_session(
    p_conv_id uuid,
    p_gen_id uuid,
    p_plan_id uuid,
    p_success boolean
)
returns void
language plpgsql
as $$
declare
    v_is_generating boolean;
    v_session_plan_id uuid;
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

    -- Lock the generation session row and verify it belongs to the chat
    select gs.plan_id
      into v_session_plan_id
      from public.generation_sessions gs
     where gs.id = p_gen_id
       and gs.conv_id = p_conv_id
     for update;

    if not found then
        raise exception 'Generation session not found';
    end if;

    if v_session_plan_id is distinct from p_plan_id then
        raise exception 'Plan ID mismatch for generation session';
    end if;

    -- Lock the task row to serialize status updates
    perform 1
      from public.project_tasks pt
     where pt.id = p_plan_id
       and pt.conv_id = p_conv_id
     for update;

    if not found then
        raise exception 'Task not found';
    end if;

    update public.chats
       set is_generating = false
     where id = p_conv_id;

    update public.generation_sessions
       set step = 'completed',
           last_modified = now()
     where id = p_gen_id
       and conv_id = p_conv_id;

    -- Update task status based on whether the generation succeeded
    -- NOTE: dynamic SQL avoids referencing newly-added enum labels in the same migration transaction.
    if p_success then
        execute
            'update public.project_tasks
                set status = ''implemented''
              where id = $1
                and conv_id = $2'
            using p_plan_id, p_conv_id;
    else
        execute
            'update public.project_tasks
                set status = ''failed''
              where id = $1
                and conv_id = $2'
            using p_plan_id, p_conv_id;
    end if;
end;
$$;
