#!/usr/bin/env bash
set -euo pipefail
# args: shardIndex(1) nodeIndex(1)
mongod --shardsvr --replSet shard1RS --port 27018 --bind_ip_all &
pid=$!

source /scripts/common-wait.sh
wait_ping localhost 27018

# инициализацию делает только первый узел
if [[ "${2:-}" == "1" ]]; then
  # ждём пиров, чтобы RS видел все хосты
  for h in shard1-1 shard1-2 shard1-3; do
    wait_ping "$h" 27018
  done
  mongosh --quiet --port 27018 --eval '
    try{
      rs.initiate({_id:"shard1RS",members:[
        {_id:0,host:"shard1-1:27018"},
        {_id:1,host:"shard1-2:27018"},
        {_id:2,host:"shard1-3:27018"}
      ]})
    }catch(e){}
  '
  wait_primary localhost 27018
fi

wait $pid