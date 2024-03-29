# Домашнее задание к занятию "Запуск приложений в K8S"

### Цель задания

В тестовой среде для работы с Kubernetes, установленной в предыдущем ДЗ, необходимо развернуть Deployment с приложением, состоящим из нескольких контейнеров и масштабировать его.

------

### Чеклист готовности к домашнему заданию

1. Установленное k8s-решение (например, MicroK8S)
2. Установленный локальный kubectl
3. Редактор YAML-файлов с подключенным git-репозиторием

------

### Инструменты/ дополнительные материалы, которые пригодятся для выполнения задания

1. [Описание](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) Deployment и примеры манифестов
2. [Описание](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) Init-контейнеров
3. [Описание](https://github.com/wbitt/Network-MultiTool) Multitool

------

### Задание 1. Создать Deployment и обеспечить доступ к репликам приложения из другого Pod'а

1. Создать Deployment приложения состоящего из двух контейнеров - nginx и multitool. Решить возникшую ошибку
2. После запуска увеличить кол-во реплик работающего приложения до 2
3. Продемонстрировать кол-во подов до и после масштабирования
 
   [Конфиг Pod1]:https://github.com/flibook/devops-netology/blob/main/12-kubernetes-03-base-run-app/deployment.yaml <br />

   [Конфиг Pod2]:https://github.com/flibook/devops-netology/blob/main/12-kubernetes-03-base-run-app/multitool.yaml <br />
   
   ![До](./before.png) <br />

   ![После](./after.png) <br />
   
4. Создать Service, который обеспечит доступ до реплик приложений из п.1
5. Создать отдельный Pod с приложением multitool и убедиться с помощью `curl` что из пода есть доступ до приложений из п.1

------

### Задание 2. Создать Deployment и обеспечить старт основного контейнера при выполнении условий

1. Создать Deployment приложения nginx и обеспечить старт контейнера только после того, как будет запущен сервис этого приложения
2. Убедиться, что nginx не стартует. В качестве init-контейнера взять busybox
   [Конфиг Pod1]:https://github.com/flibook/devops-netology/blob/main/12-kubernetes-03-base-run-app/init.yml.yaml
3. Создать и запустить Service. Убедиться, что nginx запустился
4. Продемонстрировать состояние пода до и после запуска сервиса
   
   ![Before](./init-1.png) <br />

   ![After](./init-2.png) <br />

------

### Правила приема работы

1. Домашняя работа оформляется в своем Git репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд `kubectl`, а также скриншоты результатов
3. Репозиторий должен содержать файлы манифестов и ссылки на них в файле README.md

------
