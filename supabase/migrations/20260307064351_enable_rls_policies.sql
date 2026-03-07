-- Enable RLS
alter table public.chats enable row level security;

alter table public.messages enable row level security;

alter table public.chat_tool_calls enable row level security;

alter table public.project_context enable row level security;

alter table public.project_tasks enable row level security;

alter table public.project_questions enable row level security;

alter table public.project_sites enable row level security;

create policy "Users can manage own chats" on public.chats for all using ((select auth.uid ()) = user_id)
with
    check ((select auth.uid ()) = user_id);

create policy "Users can manage own messages" on public.messages for all using (
    exists (
        select
            1
        from
            public.chats c
        where
            c.id = messages.conv_id
            and c.user_id = (select auth.uid ())
    )
)
with
    check (
        exists (
            select
                1
            from
                public.chats c
            where
                c.id = messages.conv_id
                and c.user_id = (select auth.uid ())
        )
    );

create policy "Users can manage own tool calls" on public.chat_tool_calls for all using (
    exists (
        select
            1
        from
            public.chats c
        where
            c.id = chat_tool_calls.conv_id
            and c.user_id = (select auth.uid ())
    )
)
with
    check (
        exists (
            select
                1
            from
                public.chats c
            where
                c.id = chat_tool_calls.conv_id
                and c.user_id = (select auth.uid ())
        )
    );

create policy "Users can manage own project context" on public.project_context for all using (
    exists (
        select
            1
        from
            public.chats c
        where
            c.id = project_context.id
            and c.user_id = (select auth.uid ())
    )
)
with
    check (
        exists (
            select
                1
            from
                public.chats c
            where
                c.id = project_context.id
                and c.user_id = (select auth.uid ())
        )
    );

create policy "Users can manage own project tasks" on public.project_tasks for all using (
    exists (
        select
            1
        from
            public.chats c
        where
            c.id = project_tasks.conv_id
            and c.user_id = (select auth.uid ())
    )
)
with
    check (
        exists (
            select
                1
            from
                public.chats c
            where
                c.id = project_tasks.conv_id
                and c.user_id = (select auth.uid ())
        )
    );

create policy "Users can manage own project questions" on public.project_questions for all using (
    exists (
        select
            1
        from
            public.chats c
        where
            c.id = project_questions.conv_id
            and c.user_id = (select auth.uid ())
    )
)
with
    check (
        exists (
            select
                1
            from
                public.chats c
            where
                c.id = project_questions.conv_id
                and c.user_id = (select auth.uid ())
        )
    );

create policy "Users can select own project sites" on public.project_sites for
select
    using (
        exists (
            select
                1
            from
                public.chats c
            where
                c.id = project_sites.conv_id
                and c.user_id = (select auth.uid ())
        )
    );
