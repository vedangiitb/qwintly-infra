-- ============================================================
-- RPC: finish_generation
--
-- Inputs:
-- - p_gen_id (uuid)
-- - p_success (boolean)
--
-- Behavior:
-- - Derive (chatId, planId) from generation_sessions.id
-- - Lock chats row, generation_sessions row, and project_tasks row
-- - Set chats.is_generating=false
-- - Set generation_sessions.step='completed' (+ status/message_id/last_modified)
-- - Set project_tasks.status to implemented/failed
--
-- Notes:
-- - SECURITY DEFINER is required because generation_sessions currently has no SELECT
--   policy for authenticated users; we still enforce chat ownership explicitly.
-- ============================================================

drop function if exists public.finish_generation(uuid, boolean);

create or replace function public.finish_generation(
    p_gen_id uuid,
    p_success boolean
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
    v_user_id uuid;
    v_is_service_role boolean;
    v_conv_id uuid;
    v_plan_id uuid;
    v_chat_user_id uuid;
    v_is_generating boolean;
    v_message_id uuid;
begin
    v_user_id := auth.uid();
    v_is_service_role := (auth.role() = 'service_role');

    if (not v_is_service_role) and v_user_id is null then
        raise exception using
            errcode = '42501',
            message = 'Unauthorized';
    end if;

    -- 1) Get chatId & planId based on gen_id (lock the session row)
    select gs.conv_id, gs.plan_id
      into v_conv_id, v_plan_id
      from public.generation_sessions gs
     where gs.id = p_gen_id
     for update;

    if not found then
        raise exception 'Generation session not found';
    end if;

    if v_plan_id is null then
        raise exception 'Generation session has no plan_id';
    end if;

    -- 2) Lock the chats row
    select c.is_generating, c.user_id
      into v_is_generating, v_chat_user_id
      from public.chats c
     where c.id = v_conv_id
     for update;

    if not found then
        raise exception 'Chat not found';
    end if;

    if (not v_is_service_role) and v_chat_user_id is distinct from v_user_id then
        raise exception using
            errcode = '42501',
            message = 'Unauthorized: chat does not belong to user';
    end if;

    if not v_is_generating then
        raise exception 'Chat is not generating';
    end if;

    -- 3) Lock the task row
    perform 1
      from public.project_tasks pt
     where pt.id = v_plan_id
       and pt.conv_id = v_conv_id
     for update;

    if not found then
        raise exception 'Task not found';
    end if;

    -- 4) Set is_generating false on chats
    update public.chats
       set is_generating = false
     where id = v_conv_id;

    -- 5) Write generation summary message and capture its id
    insert into public.messages (conv_id, role, content, msg_type)
    values (
        v_conv_id,
        'model'::public.roles,
        case
            when p_success then 'Generation completed'
            else 'Generation failed'
        end,
        'gen_summary'::public.msg_type
    )
    returning id into v_message_id;

    -- Persist status on the generation session itself (including message reference)
    update public.generation_sessions
       set step = 'completed',
           status = case
               when p_success then 'implemented'::public.task_status
               else 'failed'::public.task_status
           end,
           message_id = v_message_id,
           last_modified = now()
     where id = p_gen_id
       and conv_id = v_conv_id;

    -- Update task status based on whether the generation succeeded
    if p_success then
        update public.project_tasks
           set status = 'implemented'
         where id = v_plan_id
           and conv_id = v_conv_id;
    else
        update public.project_tasks
           set status = 'failed'
         where id = v_plan_id
           and conv_id = v_conv_id;
    end if;
end;
$$;

grant execute on function public.finish_generation(uuid, boolean) to authenticated;
grant execute on function public.finish_generation(uuid, boolean) to service_role;
