#!/usr/bin/env bash
set -euo pipefail

echo "[verify] Дёргаю эндпоинт /helloDoc/users (с замером времени)…"
curl -o /dev/null -s -w "[verify] Total time: %{time_total}s\n" \
     -X GET 'http://localhost:8080/helloDoc/users' \
     -H 'accept: application/json'

echo
echo "[verify] Проверяю Redis…"

# Проверка доступности
docker compose exec -T redis redis-cli ping

# Количество ключей в db0
echo -n "dbsize = "
docker compose exec -T redis redis-cli dbsize

# Показать до 10 ключей
echo "[verify] Первые ключи в Redis:"
docker compose exec -T redis redis-cli --scan | head -n 10

echo
echo "[verify] Дёргаю эндпоинт /helloDoc/users (с замером времени после добавления кеша)…"
curl -o /dev/null -s -w "[verify] Total time: %{time_total}s\n" \
     -X GET 'http://localhost:8080/helloDoc/users' \
     -H 'accept: application/json'