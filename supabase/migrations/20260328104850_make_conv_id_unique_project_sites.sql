alter table public.project_sites
add constraint project_sites_conv_id_unique unique (conv_id);

alter table public.project_sites
alter column url set not null;

alter table public.project_sites
alter column cloudrun_url set not null;

alter table public.project_sites
alter column version set not null;