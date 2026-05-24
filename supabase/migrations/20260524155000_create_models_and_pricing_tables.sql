-- ============================================================
-- Migration: create_models_and_pricing_tables
-- ============================================================

-- 1) Create providers table
create table if not exists public.providers (
    id uuid primary key default gen_random_uuid(),
    provider text not null unique,
    enabled boolean not null default true
);

-- Enable RLS for providers
alter table public.providers enable row level security;

-- Policy to allow authenticated users to read providers
create policy "Allow authenticated users to read providers"
    on public.providers for select
    to authenticated using (true);


-- 2) Create models table
create table if not exists public.models (
    id uuid primary key default gen_random_uuid(),
    model_name text not null,
    provider_id uuid not null references public.providers (id) on delete cascade,
    enabled boolean not null default true,
    unique (model_name, provider_id)
);

-- Enable RLS for models
alter table public.models enable row level security;

-- Policy to allow authenticated users to read models
create policy "Allow authenticated users to read models"
    on public.models for select
    to authenticated using (true);


-- 3) Create models_pricing table
create table if not exists public.models_pricing (
    id uuid primary key references public.models (id) on delete cascade,
    input_cost numeric(10,2) not null,
    output_cost numeric(10,2) not null
);

-- Enable RLS for models_pricing
alter table public.models_pricing enable row level security;

-- Policy to allow authenticated users to read models_pricing
create policy "Allow authenticated users to read models_pricing"
    on public.models_pricing for select
    to authenticated using (true);
