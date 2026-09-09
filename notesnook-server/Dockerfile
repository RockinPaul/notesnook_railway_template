# Notesnook sync API. Wrapper bakes the fixed self-hosted settings, the bind/discovery port,
# this service's Mongo database, and the S3/MinIO bucket + region. Credentials and the public
# attachment URL stay as Railway variables (references to the minio service).
FROM streetwriters/notesnook-sync:v1.0-beta.36
ENV SELF_HOSTED=1 \
    IDENTITY_SERVER_PORT=8080 \
    NOTESNOOK_SERVER_PORT=8080 \
    SSE_SERVER_PORT=8080 \
    MONGODB_DATABASE_NAME=notesnook \
    S3_BUCKET_NAME=attachments \
    S3_INTERNAL_BUCKET_NAME=attachments \
    S3_REGION=us-east-1 \
    NOTESNOOK_APP_HOST=https://app.notesnook.com \
    NOTESNOOK_APP_PUBLIC_URL=https://app.notesnook.com
