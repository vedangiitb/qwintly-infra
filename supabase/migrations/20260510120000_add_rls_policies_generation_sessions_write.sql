-- =========================
-- RLS Policies: generation_sessions (write access)
--
-- Allow authenticated users to insert/update/delete generation_sessions rows
-- only when they own the associated chat (via generation_sessions.conv_id).
-- =========================

create policy "Users can insert own generation sessions" on public.generation_sessions for
insert
    to authenticated
    with check (
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

create policy "Users can update own generation sessions" on public.generation_sessions for
update
    to authenticated
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
    )
    with check (
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

create policy "Users can delete own generation sessions" on public.generation_sessions for
delete
    to authenticated
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

