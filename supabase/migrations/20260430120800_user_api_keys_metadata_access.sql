-- Expose user_api_keys metadata safely.
-- Note: RLS cannot be enabled on views, so access control must live on the table.

-- Replace the original "No select for users" policy with an owner-only metadata policy.
drop policy if exists "No select for users" on public.user_api_keys;
drop policy if exists "Users can view own api keys metadata" on public.user_api_keys;

create policy "Users can view own api keys metadata" on public.user_api_keys for
select
    to authenticated using (auth.uid () = user_id);

-- Prevent selecting the encrypted key while allowing metadata reads.
revoke select (encrypted_key) on public.user_api_keys from authenticated;
revoke select (encrypted_key) on public.user_api_keys from anon;

grant
select
    (id, user_id, provider, created_at, updated_at, key_version) on public.user_api_keys to authenticated;
