#!/usr/bin/env bash
set -euo pipefail

wait_ping () {
  local host="$1" port="$2"
  until mongosh --quiet --host "${host}" --port "${port}" --eval 'db.runCommand({ping:1})' >/dev/null 2>&1; do
    sleep 2
  done
}

wait_primary () {
  local host="$1" port="$2"
  until mongosh --quiet --host "${host}" --port "${port}" --eval 'rs.isMaster().ismaster' 2>/dev/null | grep -q true; do
    sleep 2
  done
}