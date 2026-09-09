# Notesnook Sync Server on Railway

Self-host the [Notesnook](https://notesnook.com) sync server: a private, end-to-end
encrypted notes backend that the official Notesnook apps (web, desktop, mobile) connect to
instead of Notesnook's own servers. Your notes stay end-to-end encrypted either way;
self-hosting means the encrypted data never leaves your infrastructure.

This template deploys the six services the sync server needs, wires them together, and gives
each public service its own HTTPS domain.

## What gets deployed

| Service | Image | Public | Purpose |
|---|---|---|---|
| `mongo` | `mongo:7.0.12` (thin wrapper) | no | Database, run as a single-node replica set |
| `minio` | `minio/minio` (thin wrapper) | yes | S3 storage for attachments |
| `identity` | `streetwriters/identity` | yes | Authentication / OpenID Connect |
| `notesnook-server` | `streetwriters/notesnook-sync` | yes | The sync API |
| `sse` | `streetwriters/sse` | yes | Realtime change events |
| `monograph` | `streetwriters/monograph` | yes | Published-note pages |

The `mongo` and `minio` images are thin wrappers in this repo. `mongo` initiates the
replica set at startup (upstream does this from a Docker healthcheck, which Railway does not
run), and `minio` creates the `attachments` bucket and keeps its data in a subdirectory of
the volume so Railway's root-owned `lost+found` is not mistaken for a bucket. The four app
services run stock upstream images pinned by tag.

## Connecting a Notesnook app

Notesnook does not ship a hosted client for your server; you point an official app at it.
In the Notesnook app open **Settings → Servers**, enter the four URLs below, test, and save.
The app restarts against your infrastructure.

| Field in the app | Value |
|---|---|
| Notesnook Sync Server | the `notesnook-server` domain |
| Notesnook Identity Server | the `identity` domain |
| Notesnook Events Server | the `sse` domain |
| Notesnook Monograph Server | the `monograph` domain |

All four are validated together; you cannot self-host the sync server and leave the others
pointing at Notesnook. Attachments are served from the `minio` domain, which the sync server
hands to the app automatically.

## First run

1. Deploy the template. Every service must reach **healthy**; the app services wait for
   MongoDB and MinIO, so the first boot takes a couple of minutes.
2. Leave `DISABLE_SIGNUPS` set to `false` for now.
3. Point an official Notesnook app at your four URLs (above) and create your account.
4. Set `DISABLE_SIGNUPS` to `true` and redeploy `identity`, so no one else can register.

## Variables

Most values are wired for you with cross-service references. You provide the secrets.

| Variable | Where | Default | Purpose |
|---|---|---|---|
| `NOTESNOOK_API_SECRET` | identity, notesnook-server, sse | generated (64 hex) | Shared secret the services use to validate access tokens. Must match across the three. |
| `MINIO_ROOT_USER` | minio, notesnook-server | generated | MinIO access key ID. |
| `MINIO_ROOT_PASSWORD` | minio, notesnook-server | generated | MinIO secret key. |
| `INSTANCE_NAME` | all | `my-notesnook-server` | Shown by the apps on the login screen. |
| `DISABLE_SIGNUPS` | identity | `false` | Set `true` after you create your account. |
| `SMTP_HOST`, `SMTP_PORT`, `SMTP_USERNAME`, `SMTP_PASSWORD` | identity, notesnook-server | empty | Email for password reset and email-based 2FA. See the SMTP note below. |

The public URLs (`AUTH_SERVER_PUBLIC_URL`, `NOTESNOOK_API_PUBLIC_URL`,
`ATTACHMENTS_SERVER_PUBLIC_URL`, `MONOGRAPH_PUBLIC_URL`) and the internal discovery hosts are
set from Railway's per-service domains automatically, so you normally do not touch them.

## SMTP is optional, but read this

Without SMTP configured, the server cannot send email. Password reset stops working, and
**email-based two-factor authentication cannot deliver its codes.** Email 2FA is the default
for a new account, so after you sign up, immediately switch 2FA to an authenticator app under
**Settings → Auth**, or set the `SMTP_*` variables before you create the account. If you skip
both, you can lock yourself out.

## How it fits together

- The apps reach `identity`, `notesnook-server`, `sse` and `monograph` over HTTPS on their
  public domains. Attachments upload and download go straight to `minio` over presigned URLs,
  which the sync server signs against the public `minio` domain.
- The services reach each other over Railway's private network by service name, in plain
  HTTP. The OpenID Connect issuer and the API's token authority are both the private identity
  host, so token validation between the services is self-consistent; the apps do not check
  the issuer.
- MongoDB runs as a single-node replica set because the server uses transactions. The replica
  set advertises the `mongo` service's private domain, which is the host the other services
  dial.
- Data lives on two volumes: MongoDB on the `mongo` service, attachments on the `minio`
  service. Both survive redeploys.

## Component licenses

The thin wrapper files in this repository are MIT licensed (see `LICENSE`). The deployed
images carry their own licenses: the Notesnook sync server components
(`streetwriters/notesnook-sync`, `identity`, `sse`) are AGPL-3.0, `monograph` is part of the
GPL-3.0 Notesnook monorepo, MongoDB is SSPL, and MinIO is AGPL-3.0.
