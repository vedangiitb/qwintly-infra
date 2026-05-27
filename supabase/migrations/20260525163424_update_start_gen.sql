drop function if exists public.start_generation(uuid, uuid);

create or replace function public.start_generation(
    p_chat_id uuid,
    p_plan_id uuid
)
returns table (
    prev_session_id uuid,
    request_type text,
    model text,
    provider text,
    user_id uuid,
    session_id uuid,
    byok_enabled boolean
)
language plpgsql
security definer
set search_path = public
as $$
declare
    v_user_id uuid;
    v_is_service_role boolean;
    v_chat_user_id uuid;
    v_is_generating boolean;
    v_task_status text;
    v_prev_session_id uuid;
    v_provider text;
    v_model text;
    v_byok_enabled boolean;
    v_has_key boolean;
    v_execution_mode public.exec_mode;
    v_limit integer;
    v_week_start timestamptz;
    v_all_count bigint;
    v_implemented_count bigint;
    v_session_id uuid;
begin
    -- 1) Validate user from JWT
    v_user_id := auth.uid();
    v_is_service_role := (auth.role() = 'service_role');

    if (not v_is_service_role) and v_user_id is null then
        raise exception using
            errcode = '42501',
            message = 'Unauthorized';
    end if;

    -- Lock the chat row to prevent concurrent starts (also captures ownership)
    select c.is_generating, c.user_id
      into v_is_generating, v_chat_user_id
      from public.chats c
     where c.id = p_chat_id
     for update;

    if not found then
        raise exception 'Chat not found';
    end if;

    if (not v_is_service_role) and v_chat_user_id is distinct from v_user_id then
        raise exception using
            errcode = '42501',
            message = 'Unauthorized: chat does not belong to user';
    end if;

    -- For service_role calls without an end-user JWT, treat the chat owner as the effective user.
    if v_user_id is null then
        v_user_id := v_chat_user_id;
    end if;

    if v_is_generating then
        raise exception 'Chat is already generating';
    end if;

    -- Load user preferences (provider/model, and byok_enabled)
    select up.pref_provider, up.pref_model, up.byok_enabled
      into v_provider, v_model, v_byok_enabled
      from public.user_preferences up
     where up.id = v_user_id;

    if not found then
        v_byok_enabled := false;
        v_provider := 'gemini';
        v_model := 'gemini-3.1-flash-lite';
    else
        v_byok_enabled := coalesce(v_byok_enabled, false);
        v_provider := coalesce(v_provider, 'gemini');
        v_model := coalesce(v_model, 'gemini-3.1-flash-lite');
    end if;

    v_provider := lower(trim(v_provider));

    -- Check if user has an API key for preferred provider
    select exists (
        select 1
          from public.user_api_keys_safe uaks
         where uaks.user_id = v_user_id
           and uaks.provider = v_provider
    )
    into v_has_key;

    -- Determine flow based on BYOK enablement and presence of API key
    if v_byok_enabled and v_has_key then
        -- BYOK Flow
        v_execution_mode := 'byok'::public.exec_mode;
    else
        -- Free Flow (or fallback to free if API key is missing)
        v_byok_enabled := false;
        v_provider := 'gemini';
        v_model := 'gemini-3.1-flash-lite';
        v_execution_mode := 'free'::public.exec_mode;

        -- Load generation limits
        select ul.gen_limit
          into v_limit
          from public.usage_limits ul
         where ul.user_id = v_user_id;

        if not found then
            v_limit := 1; -- Fallback limit
        end if;

        -- Calculate start of the current week (Sunday 00:00)
        v_week_start := date_trunc('day', now()) - (extract(dow from now()) * interval '1 day');

        -- Count free generations for the current week
        select count(*), count(*) filter (where gs.status = 'implemented')
          into v_all_count, v_implemented_count
          from public.generation_sessions gs
          join public.chats c on gs.conv_id = c.id
         where c.user_id = v_user_id
           and gs.session_type = 'generate'
           and gs.execution_mode = 'free'
           and gs.created_at >= v_week_start;

        if v_implemented_count >= v_limit or v_all_count >= 2 * v_limit then
            raise exception using
                errcode = 'P0001',
                message = 'weekly limit exhausted';
        end if;
    end if;

    -- Determine prev_session_id and request_type
    select gs.id
      into v_prev_session_id
      from public.generation_sessions gs
     where gs.conv_id = p_chat_id
       and gs.session_type = 'generate'::public.session_type
     order by gs.last_modified desc
     limit 1;

    -- Lock the task row as well to prevent concurrent starts for the same plan/task
    select pt.status::text
      into v_task_status
      from public.project_tasks pt
     where pt.id = p_plan_id
       and pt.conv_id = p_chat_id
     for update;

    if not found then
        raise exception 'Task not found';
    end if;

    if v_task_status not in ('pending', 'updated', 'failed') then
        raise exception 'Task is not startable (status=%)', v_task_status;
    end if;

    update public.chats
       set is_generating = true
     where id = p_chat_id;

    -- Mark only the selected plan/task as "implementing"
    execute
        'update public.project_tasks
            set status = ''implementing''
          where id = $1
            and conv_id = $2'
        using p_plan_id, p_chat_id;

    -- Create generation session with designated execution_mode
    insert into public.generation_sessions (conv_id, plan_id, step, session_type, execution_mode)
    values (p_chat_id, p_plan_id, 'initiating', 'generate'::public.session_type, v_execution_mode)
    returning id into v_session_id;

    return query
    select
        v_prev_session_id as prev_session_id,
        case when v_prev_session_id is null then 'new' else 'update' end as request_type,
        v_model as model,
        v_provider as provider,
        v_user_id as user_id,
        v_session_id as session_id,
        v_byok_enabled as byok_enabled;
end;
$$;