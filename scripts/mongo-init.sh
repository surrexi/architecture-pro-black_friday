#!/usr/bin/env bash
set -euo pipefail

# Инициализация данных в шардированном кластере через mongos.
# Требования: docker compose up -d (кластер поднят и mongos healthy).

echo "[init] Проверяю готовность mongos…"
until docker compose exec -T mongos mongosh --quiet --eval 'sh.status()' >/dev/null 2>&1; do
  sleep 2
done
echo "[init] mongos готов."

echo "[init] Наполняю somedb данными…"
docker compose exec -T mongos mongosh <<'EOF'

sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )

use somedb

for (let i = 0; i < 1000; i++) {
  db.helloDoc.insertOne({ age: i, name: "ly" + i })
}

EOF

echo "[init] Готово."