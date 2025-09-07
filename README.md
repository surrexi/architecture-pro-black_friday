# pymongo-api

Шардированный кластер MongoDB (2 шарда × 3 реплики) + mongos-роутер + config server, а также Redis. Приложение подключается к MongoDB через `mongos` и к Redis по внутреннему имени сервиса.

## Как запустить

Поднимаем кластер MongoDB, Redis и приложение:

```shell
docker compose up -d
```

Заполняем MongoDB данными (через mongos):

```shell
./scripts/mongo-init.sh
```

## Как проверить

### Проверка наполненности данными mongoDB с шардами и репликами

```shell
./scripts/mongo-verify.sh
```

### Проверка кеширования в Redis

```shell
./scripts/redis-verify.sh
```

### Если вы запускаете проект на локальной машине

Откройте в браузере http://localhost:8080

### Если вы запускаете проект на предоставленной виртуальной машине

Узнать белый ip виртуальной машины

```shell
curl --silent http://ifconfig.me
```

Откройте в браузере http://<ip виртуальной машины>:8080

## Доступные эндпоинты

Список доступных эндпоинтов, swagger http://<ip виртуальной машины>:8080/docs