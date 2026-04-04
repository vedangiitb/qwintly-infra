-- ============================================================
-- RPC: persist_generation_event
-- Purpose:
-- Atomically insert a generation event with a per-session sequence
-- number (gen_id, seq_num) using a row-level lock on the session.
-- ============================================================

create or replace function public.persist_generation_event(
    p_conv_id uuid,
    p_gen_id uuid,
    p_event_type event_type,
    p_step gen_step,
    p_message text,
    p_source text
)
returns public.generation_events
language plpgsql
as $$
declare
    v_seq_num integer;
    v_event public.generation_events;
begin
    -- Lock the generation session row to serialize seq_num assignment
    perform 1
      from public.generation_sessions gs
     where gs.id = p_gen_id
       and gs.conv_id = p_conv_id
     for update;

    if not found then
        raise exception 'Generation session not found';
    end if;

    select coalesce(max(ge.seq_num), 0) + 1
      into v_seq_num
      from public.generation_events ge
     where ge.gen_id = p_gen_id;

    insert into public.generation_events (
        conv_id,
        gen_id,
        event_type,
        step,
        message,
        source,
        seq_num,
        last_modified
    )
    values (
        p_conv_id,
        p_gen_id,
        p_event_type,
        p_step,
        p_message,
        p_source,
        v_seq_num,
        now()
    )
    returning * into v_event;

    return v_event;
end;
$$;
