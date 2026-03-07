-- =========================
-- TABLE: chats
-- =========================
create table
    public.chats (
        id uuid primary key default gen_random_uuid (),
        created_at timestamptz not null default now (),
        title text not null,
        user_id uuid not null default auth.uid () references auth.users (id) on delete cascade,
        updated_at timestamptz not null default now (),
        is_generating boolean not null default false
    );

create index idx_chats_user_updated on chats (user_id, updated_at desc);

-- =========================
-- TABLE: messages
-- =========================
create table
    public.messages (
        id uuid primary key default gen_random_uuid (),
        conv_id uuid not null references public.chats (id) on delete cascade,
        role public.roles not null,
        content text not null,
        token_count int4,
        created_at timestamptz not null default now (),
        msg_type public.msg_type not null DEFAULT 'message'
    );

create index idx_messages_conv_id ON public.messages (conv_id);

create index idx_messages_conv_id_created_at ON public.messages (conv_id, created_at DESC);

-- =========================
-- TABLE: chat_tool_calls
-- =========================
create table
    public.chat_tool_calls (
        id uuid primary key default gen_random_uuid (),
        conv_id uuid not null references public.chats (id) on delete cascade,
        message_id uuid references public.messages (id) on delete cascade,
        created_at timestamptz not null default now (),
        tool_name text not null,
        arguments jsonb not null,
        result jsonb,
        summary jsonb,
        status public.tool_call_status not null
    );

create index chat_tool_calls_conv_id_idx on public.chat_tool_calls (conv_id);

create index chat_tool_calls_message_id_idx on public.chat_tool_calls (message_id);