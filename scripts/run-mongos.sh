#!/usr/bin/env bash
set -euo pipefail
mongos --port 27017 --bind_ip_all --configdb cfgRS/configsvr:27019 &
pid=$!

source /scripts/common-wait.sh
# ждём готовности RS
for h in shard1-1 shard2-1; do wait_primary "$h" 27018; done
wait_ping configsvr 27019
wait_ping localhost 27017

# добавляем шарды и включаем шардинг (идемпотентно)
mongosh --quiet --host localhost --port 27017 --eval '
  try{ sh.addShard("shard1RS/shard1-1:27018,shard1-2:27018,shard1-3:27018") }catch(e){}
  try{ sh.addShard("shard2RS/shard2-1:27018,shard2-2:27018,shard2-3:27018") }catch(e){}
  try{ sh.enableSharding("somedb") }catch(e){}
'

wait $pid