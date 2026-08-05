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
├── secureshare.html
├── database.sql
└── README.md
```

## Supabase setup

All database setup is included in `database.sql`. Run that file in the Supabase SQL Editor. It creates the `secrets` table, the `audit_logs` table, the triggers, and the RLS policies.

### Database file

- `database.sql`

### What it includes

- Encrypted secret storage fields (`ciphertext`, `iv`) instead of plaintext secret data.
- `token_hash` lookup key.
- `audit_logs` table.
- `updated_at` trigger.
- Audit trigger.
- RLS policies for the browser app.

### RLS note

The included policies are broad enough for the demo workflow that uses the Supabase anon key from the browser. If you later add an Edge Function or backend, you should tighten the policies further.

## Configuration

In `secureshare.html`, replace:

```js
const SUPABASE_URL = '__SUPABASE_URL__';
const SUPABASE_ANON_KEY = '__SUPABASE_ANON_KEY__';
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

- The app stores only encrypted data in Supabase.
- The raw token is only used in the share URL.
- The decryption key is placed in the URL fragment, not the query string.
- The secret is marked as viewed after first reveal.
- RLS should remain enabled on the table.

## Database file

Run `database.sql` in the Supabase SQL Editor to create the tables, triggers, and RLS policies needed by the app.


## Local configuration

If you are running `secureshare.html` directly, replace these values in the file before use:

```js
const SUPABASE_URL = '__SUPABASE_URL__';
const SUPABASE_ANON_KEY = '__SUPABASE_ANON_KEY__';
```

These placeholders are intentionally kept in the repo so live credentials are not committed.

## License

This project is licensed under the MIT License.
