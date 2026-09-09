# Notesnook identity (auth) server. The upstream image is unchanged; this wrapper only bakes
# the fixed Railway-side settings so they are not composer inputs: self-hosted mode, the
# bind/discovery port (Railway routes to 8080), and this service's Mongo database.
FROM streetwriters/identity:v1.0-beta.36
ENV SELF_HOSTED=1 \
    IDENTITY_SERVER_PORT=8080 \
    NOTESNOOK_SERVER_PORT=8080 \
    SSE_SERVER_PORT=8080 \
    MONGODB_DATABASE_NAME=identity \
    NOTESNOOK_APP_HOST=https://app.notesnook.com \
    NOTESNOOK_APP_PUBLIC_URL=https://app.notesnook.com
