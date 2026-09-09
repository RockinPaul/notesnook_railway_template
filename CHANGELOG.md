# Changelog

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
