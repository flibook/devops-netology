: Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1

В этом задании вы потренируетесь в:
- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста
```
ROM centos:7

ENV ES_PKG_NAME elasticsearch-7.17.1

RUN groupadd -g 1000 elasticsearch && useradd elasticsearch -u 1000 -g 1000

RUN yum makecache && \
    yum -y install wget \
    yum -y install perl-Digest-SHA \
    yum -y install java-1.8.0-openjdk.x86_64


# Install Elasticsearch.
RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.17.1-linux-x86_64.tar.gz && \
  wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.17.1-linux-x86_64.tar.gz.sha512 && \
  shasum -a 512 -c elasticsearch-7.17.1-linux-x86_64.tar.gz.sha512 && \
  tar -xzf elasticsearch-7.17.1-linux-x86_64.tar.gz && \

  rm -f elasticsearch-7.17.1-linux-x86_64.tar.gz && \
  mv /$ES_PKG_NAME /elasticsearch

# Define mountable directories.
# VOLUME ["/data"]

# Mount elasticsearch.yml config
# ADD config/elasticsearch.yml /elasticsearch/config/elasticsearch.yml

# Define working directory.
# WORKDIR /data
RUN mkdir /var/lib/logs /var/lib/data

COPY elasticsearch.yml /elasticsearch/config

RUN chmod -R 777 /elasticsearch && \
    chmod -R 777 /var/lib/logs && \
    chmod -R 777 /var/lib/data

USER elasticsearch
# Define default command.
CMD ["/elasticsearch/bin/elasticsearch"]

# Expose ports.
#   - 9200: HTTP
#   - 9300: transport
EXPOSE 9200
EXPOSE 9300

```
[elasticsearch.yml](https://github.com/flibook/devops-netology/blob/main/06-db-05-elk/elasticsearch.yml)

- ссылку на образ в репозитории dockerhub
```
https://hub.docker.com/repository/docker/ilynx/elastic
```
- ответ `elasticsearch` на запрос пути `/` в json виде
```
{
  "name" : "ea418edfc050",
  "cluster_name" : "netology_test",
  "cluster_uuid" : "FZeE2_dSR_yKLLbP-osaMw",
  "version" : {
    "number" : "7.17.1",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "e5acb99f822233d62d6444ce45a4543dc1c8059a",
    "build_date" : "2022-02-23T22:20:54.153567231Z",
    "build_snapshot" : false,
    "lucene_version" : "8.11.1",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```

Подсказки:
- возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения

Далее мы будем работать с данным экземпляром elasticsearch.

## Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

```
Создание индексов:
curl -X PUT localhost:9200/ind-1 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 1, "number_of_replicas": 0}}'
curl -X PUT localhost:9200/ind-2 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 2, "number_of_replicas": 1}}'
curl -X PUT localhost:9200/ind-3 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 4, "number_of_replicas": 2}}'

```
Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.
```
Список индексов:
curl -X GET 'http://localhost:9200/_cat/indices?v'
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases 0dXoF2DfQey4X0bHHauF1w   1   0         44            0     41.4mb         41.4mb
green  open   ind-1            JwMz80EnTkaJcaGTbtP0rQ   1   0          0            0       226b           226b
yellow open   ind-3            FE8ksdw-SduWbuhJQHqqSw   4   2          0            0       904b           904b
yellow open   ind-2            SQm0h4SGS4Kq3SCeUMZdTw   2   1          0            0       452b           452b

Статус индексов:
curl -X GET 'http://localhost:9200/_cluster/health/ind-1?pretty'
{
  "cluster_name" : "netology_test",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 1,
  "active_shards" : 1,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}

curl -X GET 'http://localhost:9200/_cluster/health/ind-2?pretty'
{
  "cluster_name" : "netology_test",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 2,
  "active_shards" : 2,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 2,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 50.0
}

curl -X GET 'http://localhost:9200/_cluster/health/ind-3?pretty'
{
  "cluster_name" : "netology_test",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 4,
  "active_shards" : 4,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 8,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 50.0
}

```
Получите состояние кластера `elasticsearch`, используя API.
```
Статус кластера:
curl -X GET 'http://localhost:9200/_cluster/health/?pretty=true'
{
  "cluster_name" : "netology_test",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 10,
  "active_shards" : 10,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 50.0
}


```
Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?
```
Из-за того, что один сервер, соответсвенно, реплицировать некуда.
```
Удалите все индексы.
```
Удаление индексов:
curl -X DELETE 'http://localhost:9200/ind-1?pretty' 
{
  "acknowledged" : true
}
curl -X DELETE 'http://localhost:9200/ind-2?pretty' 
{
  "acknowledged" : true
}
curl -X DELETE 'http://localhost:9200/ind-3?pretty' 
{
  "acknowledged" : true
}
```

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.
```
curl -XPOST localhost:9200/_snapshot/netology_backup?pretty -H 'Content-Type: application/json' -d'{"type": "fs", "settings": { "location":"/elasticsearch/snapshots" }}'
{
  "acknowledged" : true
}
```
Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.
```
curl -X PUT http://localhost:9200/test -H 'Content-Type: application/json' -d'{ "settings": {"number_of_shards": 1, "number_of_replicas": 0}}'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "test"
}

curl -X GET 'http://localhost:9200/_cat/indices?v' 
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases 0dXoF2DfQey4X0bHHauF1w   1   0         44            0     41.4mb         41.4mb
green  open   test             gpBNxwstTG2kGEjF-U5Q9Q   1   0          0            0       226b           226b
```

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`ами.
```
curl -X PUT localhost:9200/_snapshot/netology_backup/elasticsearch?wait_for_completion=true
{"snapshot":{"snapshot":"elasticsearch","uuid":"ed0U73ORTpylzoL0sKeG4g","repository":"netology_backup","version_id":7150299,"version":"7.15.2","indices":["test",".geoip_databases"],"data_streams":[],"include_global_state":true,"state":"SUCCESS","start_time":"2021-12-09T06:56:12.048Z","start_time_in_millis":1639032972048,"end_time":"2021-12-09T06:56:13.050Z","end_time_in_millis":1639032973050,"duration_in_millis":1002,"failures":[],"shards":{"total":2,"failed":0,"successful":2},"feature_states":[{"feature_name":"geoip","indices":[".geoip_databases"]}]}}

[elasticsearch@9a4f47fbd072 snapshots]$ ll
total 44
-rw-r--r-- 1 elasticsearch elasticsearch  1425 Mar 29 09:12 index-0
-rw-r--r-- 1 elasticsearch elasticsearch     8 Mar 29 09:12 index.latest
drwxr-xr-x 6 elasticsearch elasticsearch  4096 Mar 29 09:12 indices
-rw-r--r-- 1 elasticsearch elasticsearch 29264 Mar 29 09:12 meta-E4BA4gXQSw2KZgYtb87IdQ.dat
-rw-r--r-- 1 elasticsearch elasticsearch   712 Mar 29 09:12 snap-E4BA4gXQSw2KZgYtb87IdQ.dat
```
Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.
```
curl -X DELETE 'http://localhost:9200/test?pretty'
{
  "acknowledged" : true
}

curl -X PUT "localhost:9200/test-2?pretty" -H 'Content-Type: application/json' -d'{"settings": {"number_of_shards": 1, "number_of_replicas": 0}}'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "test-2"
}
curl -X GET 'http://localhost:9200/_cat/indices?v' 
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2           FXt8NSpNQ12L6QU4o8NenQ   1   0          0            0       226b           226b
green  open   .geoip_databases 0dXoF2DfQey4X0bHHauF1w   1   0         44            0     41.4mb         41.4mb
```
[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.
```
curl -X POST "localhost:9200/_snapshot/netology_backup/elasticsearch/_restore?pretty" -H 'Content-Type: application/json' -d'{"indices": "test"}'
{
  "accepted" : true
}
anantahari@ubuntu:~$ curl -X GET 'http://localhost:9200/_cat/indices?v' 
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2           FXt8NSpNQ12L6QU4o8NenQ   1   0          0            0       226b           226b
green  open   .geoip_databases 0dXoF2DfQey4X0bHHauF1w   1   0         44            0     41.4mb         41.4mb
green  open   test             TVkabdWNSCirz4X0WKSMZg   1   0          0            0       226b           226b
```

Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

---
