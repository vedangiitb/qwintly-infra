-- =========================
-- TABLE: user_api_keys
-- =========================
create table
    public.user_api_keys (
        id uuid primary key default gen_random_uuid (),
        user_id uuid not null default auth.uid () references auth.users (id) on delete cascade,
        provider text not null,
        encrypted_key text not null,
        created_at timestamptz not null default now (),
        updated_at timestamptz not null default now (),
        key_version int4 not null default 1,
        constraint user_api_keys_provider_not_empty check (length (trim(provider)) > 0),
        constraint user_api_keys_provider_lowercase check (provider = lower(provider)),
        constraint user_api_keys_encrypted_key_not_empty check (length (trim(encrypted_key)) > 0),
        constraint user_api_keys_key_version_positive check (key_version > 0)
    );

-- Only one key per user per provider.
create unique index unique_active_key_per_provider on public.user_api_keys (user_id, provider);

-- Auto-increment key_version on updates.
create or replace function increment_key_version_column ()
returns trigger as $$
begin
    new.key_version = old.key_version + 1;
    return new;
end;
$$ language plpgsql;

-- Auto-update updated_at.
create trigger increment_key_version before
update on public.user_api_keys for each row execute procedure increment_key_version_column ();

create trigger set_updated_at before
update on public.user_api_keys for each row execute procedure update_updated_at_column ();

-- Enable RLS
alter table public.user_api_keys enable row level security;

create policy "Users can create own api keys" on public.user_api_keys for insert to authenticated
with
    check (auth.uid () = user_id);

create policy "Users can update own api keys" on public.user_api_keys for
update to authenticated using (auth.uid () = user_id)
with
    check (
        auth.uid () = user_id
        and user_id = old.user_id
        and provider = old.provider
    );

create policy "Users can delete own api keys" on public.user_api_keys for delete to authenticated using (auth.uid () = user_id);

create policy "No select for users" on public.user_api_keys for
select
    to authenticated using (false);
