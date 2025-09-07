#!/usr/bin/env bash
set -euo pipefail
mongod --shardsvr --replSet shard2RS --port 27018 --bind_ip_all &
pid=$!

source /scripts/common-wait.sh
wait_ping localhost 27018

if [[ "${2:-}" == "1" ]]; then
  for h in shard2-1 shard2-2 shard2-3; do
    wait_ping "$h" 27018
  done
  mongosh --quiet --port 27018 --eval '
    try{
      rs.initiate({_id:"shard2RS",members:[
        {_id:0,host:"shard2-1:27018"},
        {_id:1,host:"shard2-2:27018"},
        {_id:2,host:"shard2-3:27018"}
      ]})
    }catch(e){}
  '
  wait_primary localhost 27018
fi

wait $pid