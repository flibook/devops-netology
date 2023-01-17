# Домашнее задание к занятию "10.02. Системы мониторинга"

## Обязательные задания

#### 1. Опишите основные плюсы и минусы pull и push систем мониторинга.

      PUSH - Плюсы: система удобна для использования в динамически создаваемых хостах (например для контейнеров), 
             так как в противном случае система мониторинга должна будет узнавать о новых хостах для их опроса,
             Минусы: Данные от агентов передаются в открытом виде, есть риск потери данных при недоступности хоста, принимающего метрики.
      PULL - Плюсы: Единая точка конфигурирования,контроль над метриками с единой точки, возможность конеккта по SSL к агентам.
             лучший контроля за источниками метрик ,т.е. всегда известно кто откуда что передает, разными системами мониторинга можно получать одни и теже метрики,
             можно выподнять запросы метрики с изменяемой переодичность, так же запрашивать метрики в ручном режиме в обход систем сбора 
             Минусы - неудобство для динамических хостов (контейнеры) нужно динамически собирать статистику о наличии хостов

#### 2. Какие из ниже перечисленных систем относятся к push модели, а какие к pull? А может есть гибридные?

    - Prometheus        - PUSH & PULL (Гибридные)
    - TICK              - PUSH & PULL (Гибридные)
    - Zabbix            - PUSH & PULL (Гибридные)
    - VictoriaMetrics   - PUSH & PULL (Гибридные)
    - Nagios - 	PULL

#### 3. Склонируйте себе [репозиторий](https://github.com/influxdata/sandbox/tree/master) и запустите TICK-стэк, 
используя технологии docker и docker-compose.

В виде решения на это упражнение приведите выводы команд с вашего компьютера (виртуальной машины):

    - curl http://localhost:8086/ping -v
    vagrant@vagrant:~/sandbox$ curl http://localhost:8086/ping -v
    Trying ::1:8086...
    TCP_NODELAY set
    Connected to localhost (::1) port 8086 (#0)
    > GET /ping HTTP/1.1
    > Host: localhost:8086
    > User-Agent: curl/7.68.0
    > Accept: */*
    Mark bundle as not supporting multiuse
    < HTTP/1.1 204 No Content
    < Content-Type: application/json
    < Request-Id: 1944481e-7a08-11ec-8028-0242ac120003
    < X-Influxdb-Build: OSS
    < X-Influxdb-Version: 1.8.10
    < X-Request-Id: 1944481e-7a08-11ec-8028-0242ac120003
    < Date: Thu, 20 Jan 2022 15:46:14 GMT

    - curl http://localhost:8888 -v
    Trying ::1:8888...
    TCP_NODELAY set
    Connected to localhost (::1) port 8888 (#0)
    > GET / HTTP/1.1
    > Host: localhost:8888
    > User-Agent: curl/7.68.0
    > Accept: */*
    >
    Mark bundle as not supporting multiuse
    < HTTP/1.1 200 OK
    < Accept-Ranges: bytes
    < Cache-Control: public, max-age=3600
    < Content-Length: 336
    < Content-Security-Policy: script-src 'self'; object-src 'self'
    < Content-Type: text/html; charset=utf-8
    < Etag: "336820331"
    < Last-Modified: Fri, 08 Oct 2021 20:33:01 GMT
    < Vary: Accept-Encoding
    < X-Chronograf-Version: 1.9.1
    < X-Content-Type-Options: nosniff
    < X-Frame-Options: SAMEORIGIN
    < X-Xss-Protection: 1; mode=block
    < Date: Thu, 20 Jan 2022 15:46:42 GMT
    <
    Connection #0 to host localhost left intact
    <!DOCTYPE html><html><head><meta http-equiv="Content-type" content="text/html; charset=utf-8"><title>Chronograf</title>
    <link rel="icon shortcut" href="/favicon.fa749080.ico"><link rel="stylesheet" href="/src.3dbae016.css"></head><body> 
    <div id="react-root" data-basepath=""></div> <script src="/src.fab22342.js"></script> </body></html>

    - curl http://localhost:9092/kapacitor/v1/ping -v
    Trying ::1:9092...
    TCP_NODELAY set
    Connected to localhost (::1) port 9092 (#0)
    > GET /kapacitor/v1/ping HTTP/1.1
    > Host: localhost:9092
    > User-Agent: curl/7.68.0
    > Accept: */*
    >
    Mark bundle as not supporting multiuse
    < HTTP/1.1 204 No Content
    < Content-Type: application/json; charset=utf-8
    < Request-Id: 1372b4a0-7a08-11ec-8017-000000000000
    < X-Kapacitor-Version: 1.6.2
    < Date: Thu, 20 Jan 2022 15:46:04 GMT

А также скриншот веб-интерфейса ПО chronograf (`http://localhost:8888`). 

[скриншот](img/1.JPG)

P.S.: если при запуске некоторые контейнеры будут падать с ошибкой - проставьте им режим `Z`, например
`./data:/var/lib:Z`

#### 4. Перейдите в веб-интерфейс Chronograf (`http://localhost:8888`) и откройте вкладку `Data explorer`.

    - Нажмите на кнопку `Add a query`
    - Изучите вывод интерфейса и выберите БД `telegraf.autogen`
    - В `measurments` выберите mem->host->telegraf_container_id , а в `fields` выберите used_percent. 
    Внизу появится график утилизации оперативной памяти в контейнере telegraf.
    - Вверху вы можете увидеть запрос, аналогичный SQL-синтаксису. 
    Поэкспериментируйте с запросом, попробуйте изменить группировку и интервал наблюдений.

Для выполнения задания приведите скриншот с отображением метрик утилизации места на диске 
(disk->host->telegraf_container_id) из веб-интерфейса.
[скриншот](img/2.JPG)

#### 5. Изучите список [telegraf inputs](https://github.com/influxdata/telegraf/tree/master/plugins/inputs). 
Добавьте в конфигурацию telegraf следующий плагин - [docker](https://github.com/influxdata/telegraf/tree/master/plugins/inputs/docker):
```
[[inputs.docker]]
  endpoint = "unix:///var/run/docker.sock"
```

Дополнительно вам может потребоваться донастройка контейнера telegraf в `docker-compose.yml` дополнительного volume и 
режима privileged:
```
  telegraf:
    image: telegraf:1.4.0
    privileged: true
    volumes:
      - ./etc/telegraf.conf:/etc/telegraf/telegraf.conf:Z
      - /var/run/docker.sock:/var/run/docker.sock:Z
    links:
      - influxdb
    ports:
      - "8092:8092/udp"
      - "8094:8094"
      - "8125:8125/udp"
```

После настройке перезапустите telegraf, обновите веб интерфейс и приведите скриншотом список `measurments` в 
веб-интерфейсе базы telegraf.autogen . Там должны появиться метрики, связанные с docker.

[скриншот](img/3.JPG)
