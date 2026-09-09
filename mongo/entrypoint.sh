#!/bin/bash
# Start mongod as a single-node replica set and initiate it once. Clients connect with
# ?replSet=rs0, so the driver discovers the member by the host advertised in the RS config;
# that host must be the one clients dial, i.e. this service's Railway PRIVATE domain.
set -euo pipefail

: "${MONGO_REPLICA_SET_NAME:=rs0}"
: "${MONGO_PORT:=27017}"
# The member host clients will reach. On Railway RAILWAY_PRIVATE_DOMAIN is the service's
# internal name; override with MONGO_ADVERTISED_HOST if needed.
ADVERTISED_HOST="${MONGO_ADVERTISED_HOST:-${RAILWAY_PRIVATE_DOMAIN:-localhost}}"

DATA_DIR="${MONGO_DATA_DIR:-/data/db}"
mkdir -p "$DATA_DIR"

init_replica_set() {
  # Wait until mongod answers.
  for _ in $(seq 1 60); do
    if mongosh --quiet --port "$MONGO_PORT" --eval 'db.runCommand({ ping: 1 }).ok' >/dev/null 2>&1; then
      break
    fi
    sleep 2
  done

  # Already initiated? (survives restarts because the config lives on the volume.)
  if mongosh --quiet --port "$MONGO_PORT" --eval 'rs.status().ok' >/dev/null 2>&1; then
    echo "replica set already initialized"
  else
    echo "initiating replica set $MONGO_REPLICA_SET_NAME with member $ADVERTISED_HOST:$MONGO_PORT"
    # Retry: on Railway the private domain may not resolve for the first few seconds.
    for _ in $(seq 1 30); do
      if mongosh --quiet --port "$MONGO_PORT" --eval "rs.initiate({_id: '$MONGO_REPLICA_SET_NAME', members: [{_id: 0, host: '$ADVERTISED_HOST:$MONGO_PORT'}]})" >/dev/null 2>&1; then
        break
      fi
      sleep 2
    done
  fi

  # If the advertised host changed (e.g. first boot used localhost), force it to the current one.
  mongosh --quiet --port "$MONGO_PORT" --eval "
    var cfg = rs.conf();
    if (cfg.members[0].host !== '$ADVERTISED_HOST:$MONGO_PORT') {
      cfg.members[0].host = '$ADVERTISED_HOST:$MONGO_PORT';
      rs.reconfig(cfg, {force: true});
      print('reconfigured member host to $ADVERTISED_HOST:$MONGO_PORT');
    }
  " >/dev/null 2>&1 || true

  # Wait for PRIMARY so dependents that start together do not race the election.
  for _ in $(seq 1 30); do
    if [ "$(mongosh --quiet --port "$MONGO_PORT" --eval 'db.hello().isWritablePrimary' 2>/dev/null)" = "true" ]; then
      echo "replica set primary is up"
      break
    fi
    sleep 2
  done
}

init_replica_set &

exec mongod --replSet "$MONGO_REPLICA_SET_NAME" --bind_ip_all --port "$MONGO_PORT" --dbpath "$DATA_DIR"
