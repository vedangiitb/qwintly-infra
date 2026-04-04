-- =========================
-- RLS Policies for Generation Tables
-- =========================

-- Policy for generation_events: Allow owners of the associated chat to read events.
create policy "Users can view own generation events" on public.generation_events for
select
    using (
        exists (
            select
                1
            from
                public.chats c
            where
                c.id = generation_events.conv_id
                and c.user_id = (select auth.uid ())
        )
    );

-- Policy for generation_sessions: Allow owners of the associated chat to read sessions.
create policy "Users can view own generation sessions" on public.generation_sessions for
select
    using (
        exists (
            select
                1
            from
                public.chats c
            where
                c.id = generation_sessions.conv_id
                and c.user_id = (select auth.uid ())
        )
    );
