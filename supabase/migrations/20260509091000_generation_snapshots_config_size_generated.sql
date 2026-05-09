-- =========================
-- generation_snapshots: maintain config_size from page_config
-- NOTE: generated columns require an IMMUTABLE expression; pg_column_size(jsonb)
-- is not immutable, so we use a trigger instead.
-- =========================

alter table public.generation_snapshots
    add column if not exists config_size integer;

-- Backfill existing rows
update public.generation_snapshots
set
    config_size = pg_column_size (page_config);

alter table public.generation_snapshots
    alter column config_size set not null;

create or replace function public.set_generation_snapshot_config_size ()
returns trigger
language plpgsql
as $$
begin
    new.config_size := pg_column_size (new.page_config);
    return new;
end;
$$;

drop trigger if exists trg_generation_snapshots_config_size on public.generation_snapshots;

create trigger trg_generation_snapshots_config_size
before insert or update of page_config on public.generation_snapshots
for each row
execute function public.set_generation_snapshot_config_size ();
