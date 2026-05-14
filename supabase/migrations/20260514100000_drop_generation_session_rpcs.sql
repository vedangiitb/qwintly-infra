-- ============================================================
-- Drop legacy generation session RPCs
--
-- These functions were superseded by newer RPCs (e.g. start_generation/finish_generation).
-- We drop all historical signatures to ensure the RPCs are removed regardless of which
-- migration set was applied previously.
-- ============================================================

-- start_generation_session(...)
drop function if exists public.start_generation_session(uuid);
drop function if exists public.start_generation_session(uuid, uuid);
drop function if exists public.start_generation_session(uuid, uuid, public.session_type);

-- finish_generation_session(...)
drop function if exists public.finish_generation_session(uuid, uuid);
drop function if exists public.finish_generation_session(uuid, uuid, boolean);
drop function if exists public.finish_generation_session(uuid, uuid, uuid, boolean);

