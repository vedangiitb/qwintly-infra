-- RPC: get_user_limits
-- Returns the weekly generation and deployment counts and limits for the user.

drop function if exists public.get_user_limits(uuid);

create or replace function public.get_user_limits(
    p_user_id uuid default null
)
returns table (
    gen_num bigint,
    dep_num bigint,
    gen_limit integer,
    dep_limit integer
)
language plpgsql
security definer
set search_path = public
as $$
declare
    v_user_id uuid;
    v_is_service_role boolean;
    v_week_start timestamptz;
    v_gen_limit integer;
    v_dep_limit integer;
    v_gen_num bigint;
    v_dep_num bigint;
begin
    -- 1) Validate user (allow service_role without auth.uid())
    v_user_id := coalesce(p_user_id, auth.uid());
    v_is_service_role := (auth.role() = 'service_role');

    if (not v_is_service_role) and v_user_id is null then
        raise exception using
            errcode = '42501',
            message = 'Unauthorized';
    end if;

    if (not v_is_service_role) and v_user_id is distinct from auth.uid() then
        raise exception using
            errcode = '42501',
            message = 'Unauthorized';
    end if;

    -- 2) Load limits
    select ul.gen_limit, ul.deploy_limit
      into v_gen_limit, v_dep_limit
      from public.usage_limits ul
     where ul.user_id = v_user_id;

    if not found then
        v_gen_limit := 1; -- Fallback limit
        v_dep_limit := 2; -- Fallback limit
    end if;

    -- 3) Calculate start of the current week (Sunday 00:00)
    v_week_start := date_trunc('day', now()) - (extract(dow from now()) * interval '1 day');

    -- 4) Count free generations for the current week
    select count(*) filter (where gs.status = 'implemented')
      into v_gen_num
      from public.generation_sessions gs
      join public.chats c on gs.conv_id = c.id
     where c.user_id = v_user_id
       and gs.session_type = 'generate'
       and gs.execution_mode = 'free'
       and gs.created_at >= v_week_start;

    -- 5) Count free deployments for the current week
    select count(*) filter (where gs.status = 'implemented')
      into v_dep_num
      from public.generation_sessions gs
      join public.chats c on gs.conv_id = c.id
     where c.user_id = v_user_id
       and gs.session_type = 'deploy'
       and gs.execution_mode = 'free'
       and gs.created_at >= v_week_start;

    -- 6) Return query
    return query
    select
        coalesce(v_gen_num, 0) as gen_num,
        coalesce(v_dep_num, 0) as dep_num,
        v_gen_limit as gen_limit,
        v_dep_limit as dep_limit;
end;
$$;

grant execute on function public.get_user_limits(uuid) to authenticated;
grant execute on function public.get_user_limits(uuid) to service_role;
