# Notesnook Sync Server

Self-host the backend for [Notesnook](https://notesnook.com), the open-source, end-to-end
encrypted note-taking app. Deploy this template, point any official Notesnook app (web,
desktop, mobile) at your server, and your encrypted notes sync through your own
infrastructure instead of Notesnook's. The notes are end-to-end encrypted either way;
self-hosting keeps the encrypted data on machines you control.

## What you get

Six services, wired together automatically:

- **notesnook-server** — the sync API
- **identity** — authentication and OpenID Connect
- **sse** — realtime change events
- **monograph** — published-note pages
- **minio** — S3-compatible storage for attachments (own volume)
- **mongo** — database, run as a single-node replica set (own volume)

Each public service gets its own HTTPS domain. Secrets are generated for you, and the
services find each other over Railway's private network.

## After deploying

1. Wait for every service to go healthy. The first boot takes a couple of minutes because
   the app services wait for the database and storage.
2. Open an official Notesnook app, go to **Settings → Servers**, and enter your four URLs:
   the `notesnook-server`, `identity`, `sse`, and `monograph` domains. Test and save; the
   app restarts against your server.
3. Create your account, then set `DISABLE_SIGNUPS` to `true` on the `identity` service and
   redeploy it, so no one else can register.

## Two things to know

- **Two-factor auth needs email.** Without SMTP configured, the server cannot send the
  email-based 2FA codes that a new account defaults to. Right after signing up, switch 2FA to
  an authenticator app under **Settings → Auth**, or configure `SMTP_*` on the `identity` and
  `notesnook-server` services before you create the account. Otherwise you can lock yourself
  out.
- **You do not host the app itself here.** You use the official Notesnook clients pointed at
  this server. Self-hosting the web client is optional and not part of this template.

## Settings

You normally change nothing: cross-service URLs and the internal wiring are set with Railway
references, and the shared secrets are generated. The only two inputs, both on the `identity`
service, are `INSTANCE_NAME` (the name your apps show on the login screen) and
`DISABLE_SIGNUPS` (leave `false` until you have created your account).

## Licenses

The deployed images carry their own licenses: the Notesnook sync server components are
AGPL-3.0, Monograph is GPL-3.0, MongoDB is SSPL, and MinIO is AGPL-3.0. The thin wrapper
files that adapt these to Railway are MIT licensed.
