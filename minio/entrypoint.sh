#!/bin/sh
# Start MinIO, then create the attachments bucket once it is reachable. The data lives in a
# SUBDIRECTORY of the volume (/data/s3), not the volume root, so Railway's root-owned
# `lost+found` is not mistaken for a bucket.
set -eu

: "${MINIO_PORT:=9000}"
: "${MINIO_CONSOLE_PORT:=9090}"
: "${MINIO_DATA_DIR:=/data/s3}"
: "${S3_BUCKET_NAME:=attachments}"
: "${MINIO_ROOT_USER:?MINIO_ROOT_USER is required}"
: "${MINIO_ROOT_PASSWORD:?MINIO_ROOT_PASSWORD is required}"

mkdir -p "$MINIO_DATA_DIR"

create_bucket() {
  for _ in $(seq 1 60); do
    if mc alias set local "http://127.0.0.1:$MINIO_PORT" "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD" >/dev/null 2>&1; then
      mc mb --ignore-existing "local/$S3_BUCKET_NAME" >/dev/null 2>&1 && echo "bucket $S3_BUCKET_NAME ready" && return 0
    fi
    sleep 2
  done
  echo "warning: could not create bucket $S3_BUCKET_NAME" >&2
}

create_bucket &

exec minio server "$MINIO_DATA_DIR" --address ":$MINIO_PORT" --console-address ":$MINIO_CONSOLE_PORT"
