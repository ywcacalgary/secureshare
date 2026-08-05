-- Secure Share database setup

create table public.secrets (
  id uuid primary key default gen_random_uuid(),
  token_hash text not null unique,
  label text,
  ciphertext text not null,
  iv text not null,
  expires_at timestamptz not null,
  viewed boolean not null default false,
  viewed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  access_count integer not null default 0,
  last_accessed_at timestamptz
);

create table public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  secret_id uuid references public.secrets(id) on delete cascade,
  action text not null,
  old_data jsonb,
  new_data jsonb,
  created_at timestamptz not null default now()
);

alter table public.secrets enable row level security;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger secrets_set_updated_at
before update on public.secrets
for each row
execute function public.set_updated_at();

create or replace function public.log_secret_audit()
returns trigger
language plpgsql
as $$
begin
  insert into public.audit_logs (secret_id, action, old_data, new_data)
  values (
    coalesce(new.id, old.id),
    tg_op,
    case when tg_op in ('UPDATE', 'DELETE') then to_jsonb(old) end,
    case when tg_op in ('INSERT', 'UPDATE') then to_jsonb(new) end
  );
  return case when tg_op = 'DELETE' then old else new end;
end;
$$;

create trigger secrets_audit_trigger
after insert or update or delete on public.secrets
for each row
execute function public.log_secret_audit();

-- Policies for the browser app using anon key
-- These are broad enough for the demo workflow.
-- Tighten them later if you add an Edge Function or backend.

create policy "Allow public insert secrets"
on public.secrets
for insert
to anon
with check (true);

create policy "Allow public read secrets"
on public.secrets
for select
to anon
using (true);

create policy "Allow public update secrets"
on public.secrets
for update
to anon
using (true)
with check (true);