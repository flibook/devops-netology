
# 11.2. Микросервисы: принципы

>Вы работаете в крупной компанию, которая строит систему на основе микросервисной архитектуры.
>Вам как DevOps специалисту необходимо выдвинуть предложение по организации инфраструктуры, для разработки и эксплуатации.

## Задача 1: API Gateway 

>Предложите решение для обеспечения реализации API Gateway. Составьте сравнительную таблицу возможностей различных программных решений. На основе таблицы сделайте выбор решения.
>
>Решение должно соответствовать следующим требованиям:
>- Маршрутизация запросов к нужному сервису на основе конфигурации
>- Возможность проверки аутентификационной информации в запросах
>- Обеспечение терминации HTTPS
>
>Обоснуйте свой выбор.

**Ответ**

| API Gateway | Маршрутизация запросов на основе конфигурации | Проверка аутентификационной информации в запросах | Терминация HTTPS |
| :---                                                               | :---: | :---: | :---: |
| [Nginx](https://nginx.com)                                         |   v   |   v   |   v   |
| [HAProxy](https://www.haproxy.com)                                 |   v   |   v   |   v   |
| [Caddy](https://caddyserver.com)                                   |   v   |   v   |   v   |
| [Tyk](https://tyk.io)                                              |   v   |   v   |   v   |
| [Kong](https://konghq.com/products/api-gateway-platform)           |   v   |   v   |   v   |
| [Apache Apisix](https://apisix.apache.org)                         |   v   |   v   |   v   |
| [Ocelot](https://github.com/ThreeMammals/Ocelot)                   |   v   |   v   |   v   |
| [Amazon API Gateway](https://aws.amazon.com/ru/api-gateway/)       |   v   |   v   |   -   |
| [Azure](https://azure.microsoft.com/en-gb/services/api-management) |   v   |   v   |   v   |
| [Yandex API Gateway](https://cloud.yandex.ru/docs/api-gateway/)    |   v   |   v   |   v   |

В целом, каждый из сервисов имеет свои преимущества и недостатки. 
Если разрабатываемая система хостится в облаке, то удобнее было бы воспользоваться их же услугами: очень быстрый старт, возможность автоматического масштабирования, защита от DDoS-атак и т.п.
Если сервера собственные, то стоит начать с Kong (на основе Nginx), т.к. легко будет найти подходящих специалистов и много различной документации

## Задача 2: Брокер сообщений

>Составьте таблицу возможностей различных брокеров сообщений. На основе таблицы сделайте обоснованный выбор решения.
>
>Решение должно соответствовать следующим требованиям:
>- Поддержка кластеризации для обеспечения надежности
>- Хранение сообщений на диске в процессе доставки
>- Высокая скорость работы
>- Поддержка различных форматов сообщений
>- Разделение прав доступа к различным потокам сообщений
>- Протота эксплуатации
>
>Обоснуйте свой выбор.

**Ответ**

| Брокер сообщений      | Кластеризация | Хранение сообщений на диске | Высокая скорость работы | Различные форматы | Права доступа | Простота |
| :-------------------- | :-----------: | :-------------------------: | :--------------: | :----: | :-----------: | :------: |
| [Kafka](https://kafka.apache.org)                           |  +  |  +  |  +  |  -  |  +  |  -  |
| [RabbitMQ](https://www.rabbitmq.com)                        |  +  |  +  | +/- |  +  |  +  |  +  |
| [ZeroMQ](https://zeromq.org)                                |  +  |  +  |  +  |  +  |  +  |  -  |
| [ActiveMQ](https://activemq.apache.org)                     |  +  |  +  |  -  |  +  |  +  |  +  |
| [NATS](https://nats.io)                                     |  +  |  +  |  +  |  -  |  +  |  +  |
| [Redis (pub,sub)](https://redis.io)                         |  +  |  -  |  +  |  -  |  -  |  +  |
| [Amazon SQS](https://aws.amazon.com/ru/sqs/)                | N/A | N/A |  +  |  -  |  -  |  +  |
| [Yandex MQ](https://cloud.yandex.ru/services/message-queue) | N/A | N/A |  +  |  -  |  -  |  +  |

Можно использовать одно из популярных решений - RabbitMQ. Легче найти подходящих специалистов и имеется огромное сообщество для решения проблем.

## ~Задача 3: API Gateway * (необязательная)~

>### Есть три сервиса:
>
>**minio**
>- Хранит загруженные файлы в бакете images
>- S3 протокол
>
>**uploader**
>- Принимает файл, если он картинка сжимает и загружает его в minio
>- POST /v1/upload
>
>**security**
>- Регистрация пользователя POST /v1/user
>- Получение информации о пользователе GET /v1/user
>- Логин пользователя POST /v1/token
>- Проверка токена GET /v1/token/validation
>
>### Необходимо воспользоваться любым балансировщиком и сделать API Gateway:
>
>**POST /v1/register**
>- Анонимный доступ.
>- Запрос направляется в сервис security POST /v1/user
>
>**POST /v1/token**
>- Анонимный доступ.
>- Запрос направляется в сервис security POST /v1/token
>
>**GET /v1/user**
>- Проверка токена. Токен ожидается в заголовке Authorization. Токен проверяется через вызов сервиса security GET /v1/token/validation/
>- Запрос направляется в сервис security GET /v1/user
>
>**POST /v1/upload**
>- Проверка токена. Токен ожидается в заголовке Authorization. Токен проверяется через вызов сервиса security GET /v1/token/validation/
>- Запрос направляется в сервис uploader POST /v1/upload
>
>**GET /v1/user/{image}**
>- Проверка токена. Токен ожидается в заголовке Authorization. Токен проверяется через вызов сервиса security GET /v1/token/validation/
>- Запрос направляется в сервис minio  GET /images/{image}
>
>### Ожидаемый результат
>
>Результатом выполнения задачи должен быть docker compose файл запустив который можно локально выполнить следующие команды с успешным результатом.
>Предполагается что для реализации API Gateway будет написан конфиг для NGinx или другого балансировщика нагрузки который будет запущен как сервис через docker-compose и будет обеспечивать балансировку и проверку аутентификации входящих запросов.
>Авторизаци
>curl -X POST -H 'Content-Type: application/json' -d '{"login":"bob", "password":"qwe123"}' http://localhost/token
>
>**Загрузка файла**
>
>curl -X POST -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJib2IifQ.hiMVLmssoTsy1MqbmIoviDeFPvo-nCd92d4UFiN2O2I' -H 'Content-Type: octet/stream' --data-binary @yourfilename.jpg http://localhost/upload
>
>**Получение файла**
>curl -X GET http://localhost/images/4e6df220-295e-4231-82bc-45e4b1484430.jpg
>
>#### [Дополнительные материалы: как запускать, как тестировать, как проверить](https://github.com/netology-code/devkub-homeworks/tree/main/11-microservices-02-principles)