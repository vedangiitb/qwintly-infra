-- ============================================================
-- RPC: start_deployment
--
-- Inputs:
-- - p_chat_id (uuid)
-- - p_generation_session_id (uuid)  -- generation session to deploy
--
-- Outputs:
-- - model (text)
-- - provider (text)
-- - user_id (uuid)
-- - session_id (uuid)  -- newly created deployment session id
-- - plan_id (uuid)
--
-- Notes:
-- - SECURITY DEFINER is required because generation_sessions currently has no SELECT
--   policy for authenticated users; we still enforce chat ownership explicitly.
-- ============================================================

-- ================================
-- TABLE: deployment_generation_map
-- ================================
create table if not exists public.deployment_generation_map (
    deployment_session_id uuid not null
        references public.generation_sessions (id) on delete cascade,
    generation_session_id uuid not null
        references public.generation_sessions (id) on delete cascade,
    primary key (deployment_session_id, generation_session_id)
);

drop function if exists public.start_deployment(uuid, uuid);

create or replace function public.start_deployment(
    p_chat_id uuid,
    p_generation_session_id uuid
)
returns table (
    model text,
    provider text,
    user_id uuid,
    session_id uuid,
    plan_id uuid
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
    v_provider text;
    v_model text;
    v_has_key boolean;
    v_plan_id uuid;
    v_source_session_type public.session_type;
    v_session_id uuid;
begin
    -- 1) Validate user from JWT (allow service_role without auth.uid())
    v_user_id := auth.uid();
    v_is_service_role := (auth.role() = 'service_role');

    if (not v_is_service_role) and v_user_id is null then
        raise exception using
            errcode = '42501',
            message = 'Unauthorized';
    end if;

    -- 2) Lock the chat row to prevent concurrent starts
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
        raise exception 'Chat is already deploying';
    end if;

    -- 3) Load user preferences (provider/model)
    select up.pref_provider, up.pref_model
      into v_provider, v_model
      from public.user_preferences up
     where up.id = v_user_id;

    if v_provider is null or length(trim(v_provider)) = 0 then
        raise exception using
            errcode = 'P0001',
            message = 'Preferred provider not set';
    end if;

    v_provider := lower(trim(v_provider));

    -- 4) Ensure user has an API key for preferred provider
    select exists (
        select 1
          from public.user_api_keys_safe uaks
         where uaks.user_id = v_user_id
           and uaks.provider = v_provider
    )
    into v_has_key;

    if not v_has_key then
        raise exception using
            errcode = 'P0001',
            message = format('Missing API key for provider=%s', v_provider);
    end if;

    -- 5) Get plan_id from the source generation session; must be a 'generate' session for this chat
    select gs.plan_id, gs.session_type
      into v_plan_id, v_source_session_type
      from public.generation_sessions gs
     where gs.id = p_generation_session_id
       and gs.conv_id = p_chat_id;

    if not found then
        raise exception 'Generation session not found';
    end if;

    if v_source_session_type = 'deploy'::public.session_type then
        raise exception using
            errcode = 'P0001',
            message = 'Cannot deploy from a deployment session';
    end if;

    if v_plan_id is null then
        raise exception 'Generation session has no plan_id';
    end if;

    -- Mark chat as generating (deploy is part of generation pipeline)
    update public.chats
       set is_generating = true
     where id = p_chat_id;

    -- 6) Create a deployment session tied to the same chat + plan
    insert into public.generation_sessions (conv_id, plan_id, step, session_type)
    values (p_chat_id, v_plan_id, 'initiating', 'deploy'::public.session_type)
    returning id into v_session_id;

    insert into public.deployment_generation_map (deployment_session_id, generation_session_id)
    values (v_session_id, p_generation_session_id);

    return query
    select
        v_model as model,
        v_provider as provider,
        v_user_id as user_id,
        v_session_id as session_id,
        v_plan_id as plan_id;
end;
$$;

grant execute on function public.start_deployment(uuid, uuid) to authenticated;
grant execute on function public.start_deployment(uuid, uuid) to service_role;
