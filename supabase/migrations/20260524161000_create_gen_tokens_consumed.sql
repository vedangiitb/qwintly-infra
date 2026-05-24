-- ============================================================
-- Migration: create_gen_tokens_consumed
-- ============================================================

-- 1) Create gen_tokens_consumed table
create table if not exists public.gen_tokens_consumed (
    id uuid primary key default gen_random_uuid(),
    gen_id uuid not null references public.generation_sessions (id) on delete cascade,
    model uuid not null references public.models (id) on delete cascade,
    input_tokens integer not null,
    output_tokens integer not null,
    input_cost numeric(10,2) not null,
    output_cost numeric(10,2) not null
);

-- Enable RLS for gen_tokens_consumed
alter table public.gen_tokens_consumed enable row level security;

-- Policy: Users should be able to read only their own generations
create policy "Users can view own gen token usage"
    on public.gen_tokens_consumed for select
    to authenticated using (
        exists (
            select 1
            from public.generation_sessions gs
            join public.chats c on gs.conv_id = c.id
            where gs.id = gen_tokens_consumed.gen_id
              and c.user_id = auth.uid()
        )
    );

-- 2) Create persist_gen_tokens RPC
create or replace function public.persist_gen_tokens(
    p_gen_id uuid,
    p_input_tokens integer,
    p_output_tokens integer,
    p_model text
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
    v_model_id uuid;
    v_input_cost_rate numeric(10,2);
    v_output_cost_rate numeric(10,2);
    v_computed_input_cost numeric(10,2);
    v_computed_output_cost numeric(10,2);
    v_inserted_id uuid;
begin
    -- 1. Get model ID by name from models table
    select id into v_model_id
    from public.models
    where model_name = p_model
    limit 1;

    if v_model_id is null then
        raise exception 'Model % not found in models table', p_model;
    end if;

    -- 2. Get input and output cost rates from models_pricing table (rates per 1M tokens)
    select input_cost, output_cost
    into v_input_cost_rate, v_output_cost_rate
    from public.models_pricing
    where id = v_model_id;

    if not found then
        raise exception 'Pricing not found for model % (ID: %)', p_model, v_model_id;
    end if;

    -- 3. Compute cost (models_pricing are per 1M tokens)
    v_computed_input_cost := round(((p_input_tokens::numeric * v_input_cost_rate) / 1000000.0), 2);
    v_computed_output_cost := round(((p_output_tokens::numeric * v_output_cost_rate) / 1000000.0), 2);

    -- 4. Insert into gen_tokens_consumed
    insert into public.gen_tokens_consumed (
        gen_id,
        model,
        input_tokens,
        output_tokens,
        input_cost,
        output_cost
    )
    values (
        p_gen_id,
        v_model_id,
        p_input_tokens,
        p_output_tokens,
        v_computed_input_cost,
        v_computed_output_cost
    )
    returning id into v_inserted_id;

    return v_inserted_id;
end;
$$;

-- Grant execution permissions
grant execute on function public.persist_gen_tokens(uuid, integer, integer, text) to authenticated;
grant execute on function public.persist_gen_tokens(uuid, integer, integer, text) to service_role;
