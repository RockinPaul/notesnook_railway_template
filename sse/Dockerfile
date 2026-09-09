# Notesnook SSE (realtime events) server. Wrapper bakes self-hosted mode and the
# bind/discovery ports so the deployer does not set them.
FROM streetwriters/sse:v1.0-beta.36
ENV SELF_HOSTED=1 \
    IDENTITY_SERVER_PORT=8080 \
    NOTESNOOK_SERVER_PORT=8080 \
    SSE_SERVER_PORT=8080
