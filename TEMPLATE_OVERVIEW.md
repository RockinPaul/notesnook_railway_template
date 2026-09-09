# Deploy and Host Notesnook Sync Server on Railway

[Notesnook](https://notesnook.com) is an open-source, end-to-end encrypted note-taking app.
This template deploys the self-hosted Notesnook **sync server**: the backend that the official
Notesnook apps (web, desktop, mobile) connect to instead of Notesnook's own servers, so your
encrypted notes sync through infrastructure you control.

## About Hosting Notesnook Sync Server

The sync server is six cooperating services, and this template runs and wires all of them:
the sync API, the identity (authentication) server, a realtime events server, the Monograph
published-notes server, MinIO for attachment storage, and MongoDB as a single-node replica
set. Each public service receives its own HTTPS domain; the services reach each other over
Railway's private network; the shared secret and storage credentials are generated for you;
and the two data volumes (database and attachments) persist across redeploys. The container
images are pinned, and the MongoDB and MinIO images are thin wrappers that initiate the
replica set and create the attachments bucket at startup. After deploying, you point an
official Notesnook app at your four service URLs under Settings → Servers, create your
account, and then disable further signups.

## Common Use Cases

- Keep your personal notes end-to-end encrypted and synced entirely on your own server.
- Run a private Notesnook backend for a family or a small team.
- Publish selected notes as web pages through the built-in Monograph server.

## Dependencies for Notesnook Sync Server Hosting

- Docker images published by Notesnook (`streetwriters/*`), plus MongoDB and MinIO.
- An official Notesnook client (web, desktop, or mobile) to connect to the server.
- Optional SMTP credentials for password reset and email-based two-factor authentication.

### Deployment Dependencies

- [Notesnook sync server](https://github.com/streetwriters/notesnook-sync-server) — the
  upstream backend (AGPL-3.0).
- [Notesnook](https://github.com/streetwriters/notesnook) — the client apps (GPL-3.0).
- [Self-hosting guide](https://help.notesnook.com/self-hosting-notesnook-sync-server) —
  upstream documentation for connecting a client.

### Implementation Details

Six services build from this template's repository, each from its own directory:

- **identity**, **notesnook-server**, **sse** — `streetwriters/*:v1.0-beta.36`; **monograph**
  — `streetwriters/monograph:1.3.1`. Thin wrappers bake the fixed self-hosted settings (mode,
  port, database names, S3 bucket and region), so they are not deployment inputs. Healthchecks
  on `/health` and `/api/health`.
- **mongo** — `mongo:7.0.12`, wrapped to initiate a single-node replica set advertised on
  `localhost`; clients connect with `directConnection=true`. Volume at `/data`.
- **minio** — `minio/minio` with `mc`, wrapped to create the `attachments` bucket and keep
  data in a subdirectory of the volume. Healthcheck on `/minio/health/live`. Volume at `/data`.

The only settings you may change are `INSTANCE_NAME` (shown on the app's login screen) and
`DISABLE_SIGNUPS` (set to `true` after you create your account). Without SMTP configured,
switch two-factor auth to an authenticator app right after signing up, or you can lock
yourself out.

## Why Deploy Notesnook Sync Server on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your
infrastructure so you don't have to deal with configuration, while allowing you to vertically
and horizontally scale it.

By deploying Notesnook Sync Server on Railway, you are one step closer to supporting a
complete full-stack application with minimal burden. Host your servers, databases, AI agents,
and more on Railway.
