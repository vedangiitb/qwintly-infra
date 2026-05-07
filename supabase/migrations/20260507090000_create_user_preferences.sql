-- =========================
-- TABLE: user_preferences
-- =========================
create table
    public.user_preferences (
        id uuid primary key references auth.users (id) on delete cascade,
        pref_model text,
        pref_provider text
    );
    
-- Enable RLS
alter table public.user_preferences enable row level security;

create policy "Users can create own preferences" on public.user_preferences for insert to authenticated
with
    check (auth.uid () = id);

create policy "Users can read own preferences" on public.user_preferences for
select
    to authenticated using (auth.uid () = id);

create policy "Users can update own preferences" on public.user_preferences for
update to authenticated using (auth.uid () = id)
with
    check (auth.uid () = id);

create policy "Users can delete own preferences" on public.user_preferences for delete to authenticated using (auth.uid () = id);
