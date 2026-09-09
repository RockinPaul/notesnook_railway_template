# MinIO (S3 storage for attachments) for the Notesnook sync server. The stock image has no
# way to pre-create a bucket, so this image bundles the `mc` client and creates the
# attachments bucket at startup before handing off to the MinIO server.
FROM minio/mc:RELEASE.2024-07-26T13-08-44Z AS mc

FROM minio/minio:RELEASE.2024-07-29T22-14-52Z
COPY --from=mc /usr/bin/mc /usr/bin/mc
COPY --chmod=755 entrypoint.sh /usr/local/bin/minio-entrypoint.sh

# Fixed Railway-side settings: listen on the port Railway routes to, and the bucket name.
ENV MINIO_PORT=8080 \
    S3_BUCKET_NAME=attachments
ENTRYPOINT ["/usr/local/bin/minio-entrypoint.sh"]
