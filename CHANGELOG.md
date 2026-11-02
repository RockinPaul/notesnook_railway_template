# Changelog

## 2026-11-02 — sync server v1.0-beta.46

- `identity`, `notesnook-server` and `sse` run `streetwriters/*:v1.0-beta.46` (were v1.0-beta.36).
- **Security fixes:** WAMP, the services' internal RPC (password reset, user deletion, subscription changes, SSE), was reachable without authentication at `/wamp` on every public port. It now listens only on a separate internal port (each service's port + 1, so 8081 here) and requires a token derived from `NOTESNOOK_API_SECRET`. Also: refresh tokens rotate on every use, sign-in with an MFA code requires the password, password reset accepts only tokens from the reset flow, the CORS proxy refuses internal addresses, S3 object names are validated whole, and signing keys are encrypted in the database.
- Nothing to wire: the three services already share `NOTESNOOK_API_SECRET` and reach each other by private hostname, and Railway's private network carries the new port. Writes now always run in a transaction, which the template's single-node replica set supports.

### Upgrading an existing deployment

Nothing to change. **Back up `mongo` first**: the services write in transactions and re-encrypt stored keys on their first start. Redeploy `identity`, `notesnook-server` and `sse` together, since an old service cannot reach a new one's WAMP port.

## 2026-09-09 — initial release

Six services for the self-hosted Notesnook sync server, pinned:

- `identity`, `notesnook-server`, `sse` from `streetwriters/*:v1.0-beta.36`; `monograph` from
  `streetwriters/monograph:1.3.1`. Each is a thin wrapper that bakes the fixed self-hosted
  settings (self-hosted mode, the Railway port, database names, the S3 bucket and region) so
  they are not deployment inputs.
- `mongo` from `mongo:7.0.12`, wrapped to initiate a single-node replica set at startup. The
  set is advertised on `localhost` and clients connect with `directConnection=true`, because a
  single-node set on private networking cannot recognise its own overlay hostname as a member.
- `minio` from `minio/minio:RELEASE.2024-07-29T22-14-52Z` with `mc`, wrapped to create the
  `attachments` bucket and keep data in a subdirectory of the volume so a root-owned
  `lost+found` is not mistaken for a bucket.

Wiring: every inter-service URL and the shared `NOTESNOOK_API_SECRET` and MinIO credentials
are Railway references; the secret and credentials are generated with `secret()`. Each service
builds from its own directory in the repository. Volumes on `mongo` and `minio`; HTTP
healthchecks on the five public services.

### Upgrading

Bump the image tag in the relevant `<service>/Dockerfile` and redeploy that service. Volumes,
including notes, attachments and the database, are kept. Read upstream's release notes before
crossing a schema change.
