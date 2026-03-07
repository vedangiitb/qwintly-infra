-- =====================================
-- TABLE: project_questions
-- =====================================
create table
    public.project_questions (
        id uuid primary key default gen_random_uuid (),
        conv_id uuid not null references public.chats (id) on delete cascade,
        message_id uuid not null references public.messages (id) on delete cascade,
        questions jsonb not null,
        user_responses jsonb,
        status public.question_status not null default 'pending',
        tool_id uuid not null references public.chat_tool_calls (id) on delete cascade,
        created_at timestamptz not null default now ()
    );

create index project_questions_conv_id_idx on public.project_questions (conv_id);

create index project_questions_message_id_idx on public.project_questions (message_id);

-- =====================================
-- TABLE: project_tasks
-- =====================================
create table
    public.project_tasks (
        id uuid primary key default gen_random_uuid (),
        conv_id uuid not null references public.chats (id) on delete cascade,
        message_id uuid not null references public.messages (id) on delete cascade,
        content jsonb not null,
        status public.task_status not null,
        tool_id uuid not null references public.chat_tool_calls (id) on delete cascade,
        created_at timestamptz not null default now ()
    );

create index project_tasks_message_id_idx on public.project_tasks (message_id);

create index project_tasks_conv_id_idx on public.project_tasks (conv_id);

create index project_tasks_conv_created_idx on public.project_tasks (conv_id, created_at desc);

-- =====================================
-- TABLE: project_sites
-- =====================================
create table
    public.project_sites (
        id uuid primary key default gen_random_uuid (),
        conv_id uuid not null references public.chats (id) on delete cascade,
        url text not null,
        version int4 not null,
        last_modified timestamptz not null default now ()
    );

create index project_sites_conv_id_idx on public.project_sites (conv_id);

-- =====================================
-- TABLE: project_context
-- =====================================
create table
    public.project_context (
        id uuid primary key references public.chats (id) on delete cascade,
        collected_context jsonb not null,
        project_context jsonb,
        project_info jsonb,
        updated_at timestamptz not null default now ()
    );