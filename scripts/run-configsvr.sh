#!/usr/bin/env bash
set -euo pipefail
mongod --configsvr --replSet cfgRS --port 27019 --bind_ip_all &
mongod_pid=$!

# ждать, затем попытаться инициировать (идемпотентно)
source /scripts/common-wait.sh
wait_ping localhost 27019
mongosh --quiet --port 27019 --eval 'try{rs.initiate({_id:"cfgRS",configsvr:true,members:[{_id:0,host:"configsvr:27019"}]})}catch(e){}'
wait_primary localhost 27019

wait $mongod_pid