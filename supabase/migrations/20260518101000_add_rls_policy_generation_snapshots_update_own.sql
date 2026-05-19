-- =========================
-- RLS Policy: generation_snapshots (update access)
--
-- Allow authenticated users to update generation_snapshots rows only when
-- they own the associated chat (via generation_sessions.conv_id -> chats.user_id).
-- =========================

drop policy if exists "Users can update own generation snapshots" on public.generation_snapshots;

create policy "Users can update own generation snapshots" on public.generation_snapshots for
update
    to authenticated
    using (
        exists (
            select
                1
            from
                public.generation_sessions gs
                join public.chats c on c.id = gs.conv_id
            where
                gs.id = generation_snapshots.id
                and c.user_id = (select auth.uid ())
        )
    )
    with check (
        exists (
            select
                1
            from
                public.generation_sessions gs
                join public.chats c on c.id = gs.conv_id
            where
                gs.id = generation_snapshots.id
                and c.user_id = (select auth.uid ())
        )
    );

