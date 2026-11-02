# S3 storage for attachments for the Notesnook sync server: Silo, the MinIO fork upstream's
# compose file moved to once MinIO's own images were pulled from Docker Hub. The stock image
# has no way to pre-create a bucket, so this image bundles the `mc` client and creates the
# attachments bucket at startup before handing off to the server.
FROM pgsty/mc:RELEASE.2026-09-13T00-00-00Z AS mc

FROM pgsty/silo:RELEASE.2026-09-16T00-00-00Z
COPY --from=mc /usr/bin/mc /usr/bin/mc
COPY --chmod=755 entrypoint.sh /usr/local/bin/minio-entrypoint.sh

# Fixed Railway-side settings: listen on the port Railway routes to, and the bucket name.
ENV MINIO_PORT=8080 \
    S3_BUCKET_NAME=attachments
ENTRYPOINT ["/usr/local/bin/minio-entrypoint.sh"]
