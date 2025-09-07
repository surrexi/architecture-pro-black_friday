#!/usr/bin/env bash
set -euo pipefail

DB="somedb"
COLL="helloDoc"

# все узлы обоих шардов
NODES=(
  "shard1-1:27018"
  "shard1-2:27018"
  "shard1-3:27018"
  "shard2-1:27018"
  "shard2-2:27018"
  "shard2-3:27018"
)

echo "[verify] Count via mongos (роутер)"
docker compose exec -T mongos mongosh --quiet --eval \
  "db.getSiblingDB('${DB}').${COLL}.countDocuments()"

echo "[verify] Count on shard1-1 (первый узел шарда1)"
docker compose exec -T shard1-1 mongosh --quiet --port 27018 --eval \
  "db.getSiblingDB('${DB}').${COLL}.countDocuments()"

echo "[verify] Count on shard2-1 (первый узел шарда2)"
docker compose exec -T shard2-1 mongosh --quiet --port 27018 --eval \
  "db.getSiblingDB('${DB}').${COLL}.countDocuments()"

echo
echo "[verify] Counts on every replica of all shards:"
for entry in "${NODES[@]}"; do
  host="${entry%%:*}"
  port="${entry##*:}"

  # ждём, чтобы узел ответил
  until docker compose exec -T "${host}" mongosh --quiet --port "${port}" --eval \
    'db.runCommand({ping:1})' >/dev/null 2>&1; do
    sleep 1
  done

  # включаем чтение со SECONDARY и считаем
  cnt=$(docker compose exec -T "${host}" mongosh --quiet --port "${port}" --eval \
    "db.getMongo().setReadPref('primaryPreferred'); db.getSiblingDB('${DB}').${COLL}.countDocuments()")
  cnt=${cnt//$'\r'/}

  echo "  - ${host}:${port} -> ${cnt}"
done