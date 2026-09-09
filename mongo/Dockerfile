# MongoDB for the Notesnook sync server. Upstream's compose runs a single-node replica set
# (required for transactions) and initiates it from the container healthcheck. Railway
# healthchecks are HTTP-only, so this image initiates the set itself at startup instead.
FROM mongo:7.0.12

COPY --chmod=755 entrypoint.sh /usr/local/bin/rs-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/rs-entrypoint.sh"]
