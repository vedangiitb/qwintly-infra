-- ============================================================
-- Revert/Update: finish_generation_session
-- Purpose:
-- - Remove p_task_status param
-- - Set generation_sessions.status based on p_success:
--     true  -> 'implemented'
--     false -> 'failed'
-- ============================================================

-- Drop the 5-arg variant introduced in a prior migration
drop function if exists public.finish_generation_session(uuid, uuid, uuid, boolean, public.task_status);

-- Replace the 4-arg function to also update generation_sessions.status
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

    -- Persist status on the generation session itself
    update public.generation_sessions
       set step = 'completed',
           status = case
               when p_success then 'implemented'::public.task_status
               else 'failed'::public.task_status
           end,
           last_modified = now()
     where id = p_gen_id
       and conv_id = p_conv_id;

    -- Update task status based on whether the generation succeeded
    if p_success then
        update public.project_tasks
           set status = 'implemented'
         where id = p_plan_id
           and conv_id = p_conv_id;
    else
        update public.project_tasks
           set status = 'failed'
         where id = p_plan_id
           and conv_id = p_conv_id;
    end if;
end;
$$;

