# Secure Share

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Built with](https://img.shields.io/badge/built%20with-HTML%20%2F%20Tailwind%20%2F%20JavaScript-0ea5e9)](https://developer.mozilla.org/)
[![Supabase](https://img.shields.io/badge/backend-Supabase-3ecf8e)](https://supabase.com/)

Secure Share is a one-time secret sharing app that lets users generate expiring, single-use links or QR codes for sensitive credentials. It is built as a single HTML file with Tailwind CSS, JavaScript, and Supabase, with token hashing, audit-friendly fields, and a reveal-once recipient flow.

## Features

- One-time reveal flow.
- Expiring links.
- QR code generation.
- Token hashing instead of exposed IDs.
- Audit-friendly fields.
- Fade/slide reveal animation.
- Soft blur before reveal.
- Copy-to-clipboard support.
- Pure HTML frontend.

## How it works

1. Sender pastes a secret.
2. The app generates a random token.
3. The token is hashed and stored in Supabase.
4. A share link is created with the raw token.
5. Recipient opens the link and clicks **Reveal once**.
6. The secret is shown once and then marked as viewed.

## Tech stack

- HTML
- JavaScript
- Tailwind CSS
- Supabase
- QRCode.js

## Project structure

```text
secure-share/
└── secureshare.html
```

## Supabase setup

### 1. Create a table

Run this SQL in Supabase:

```sql
create table public.secrets (
  id uuid primary key default gen_random_uuid(),
  token_hash text not null unique,
  label text,
  secret_text text not null,
  expires_at timestamptz not null,
  viewed boolean not null default false,
  viewed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by text,
  viewed_by text,
  last_accessed_at timestamptz,
  access_count integer not null default 0
);

alter table public.secrets enable row level security;
```

### 2. Add update timestamp trigger

```sql
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
```

### 3. Add policies

```sql
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
```

## Configuration

In `secureshare.html`, replace:

```js
const SUPABASE_URL = 'YOUR_SUPABASE_URL';
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';
```

with your Supabase project values.

## Getting your Supabase keys

1. Open your Supabase project.
2. Go to **Settings**.
3. Select **API**.
4. Copy the **Project URL**.
5. Copy the **anon/public key**.

## Usage

1. Open `secureshare.html` in a browser.
2. Enter a secret.
3. Click **Generate secure link**.
4. Copy the link or share the QR code.
5. Recipient opens the link and clicks **Reveal once**.

## Security notes

- The app stores only the hashed token in Supabase.
- The raw token is only used in the share URL.
- The secret is marked as viewed after first reveal.
- RLS should remain enabled on the table.

## Screenshots

Add screenshots here after you run the app locally and capture the UI.

## License

This project is licensed under the MIT License.
