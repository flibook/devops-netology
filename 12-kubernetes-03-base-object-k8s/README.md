# Домашнее задание к занятию "Базовые объекты K8S"

### Цель задания

В тестовой среде для работы с Kubernetes, установленной в предыдущем ДЗ, необходимо развернуть Pod с приложением и подключиться к нему со своего локального компьютера. 

------

### Чеклист готовности к домашнему заданию

1. Установленное k8s-решение (например, MicroK8S)
2. Установленный локальный kubectl
3. Редактор YAML-файлов с подключенным git-репозиторием

------

### Инструменты/ дополнительные материалы, которые пригодятся для выполнения задания

1. Описание [Pod](https://kubernetes.io/docs/concepts/workloads/pods/) и примеры манифестов
2. Описание [Service](https://kubernetes.io/docs/concepts/services-networking/service/)

------

### Задание 1. Создать Pod с именем "hello-world"

1. Создать манифест (yaml-конфигурацию) Pod
2. Использовать image - gcr.io/kubernetes-e2e-test-images/echoserver:2.2
3. Подключиться локально к Pod с помощью `kubectl port-forward` и вывести значение (curl или в браузере)
```
Hostname: hello-world

Pod Information:
	-no pod information available-

Server values:
	server_version=nginx: 1.12.2 - lua: 10010

Request Information:
	client_address=127.0.0.1
	method=GET
	real path=/
	query=
	request_version=1.1
	request_scheme=http
	request_uri=http://127.0.0.1:8080/

Request Headers:
	accept=text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8  
	accept-encoding=gzip, deflate, br  
	accept-language=en-US,en;q=0.5  
	connection=keep-alive  
	cookie=authMode=token  
	host=127.0.0.1:8080  
	sec-fetch-dest=document  
	sec-fetch-mode=navigate  
	sec-fetch-site=none  
	sec-fetch-user=?1  
	upgrade-insecure-requests=1  
	user-agent=Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/109.0  

Request Body:
	-no body in request-
```
------

### Задание 2. Создать Service и подключить его к Pod

1. Создать Pod с именем "netology-web"
2. Использовать image - gcr.io/kubernetes-e2e-test-images/echoserver:2.2
3. Создать Service с именем "netology-svc" и подключить к "netology-web"
4. Подключиться локально к Service с помощью `kubectl port-forward` и вывести значение (curl или в браузере)

------
```
**Ответ**
1. Создание POD и Service командой:
   microk8s kubectl apply -f ./netology-web.yaml
   microk8s kubectl apply -f ./service.yaml
2. Вывод команды kubectl get pods
   NAME                     READY   STATUS    RESTARTS      AGE
   nginx-748c667d99-t9vqd   1/1     Running   5 (42h ago)   7d23h
   pod-with-app             1/1     Running   0             13h
   hello-world              1/1     Running   0             13h
   netology-web             1/1     Running   0             12h
3. Вывод команды 
   microk8s kubectl describe svc netology-svc 

   Name:              netology-svc
   Namespace:         default
   Labels:            <none>
   Annotations:       <none>
   Selector:          app=myapp
   Type:              ClusterIP
   IP Family Policy:  SingleStack
   IP Families:       IPv4
   IP:                10.152.183.145
   IPs:               10.152.183.145
   Port:              echo  80/TCP
   TargetPort:        9376/TCP
   Endpoints:         10.1.248.201:9376,10.1.248.202:9376,10.1.248.207:9376
   Session Affinity:  None
   Events:            <none>
```
3. Манифесты
   [Конфиг Pod1]:https://github.com/flibook/devops-netology/blob/main/12-kubernetes-03-base-object-k8s/config.yaml <br />

   [Конфиг Pod2]:https://github.com/flibook/devops-netology/blob/main/12-kubernetes-03-base-object-k8s/config-1.yaml <br />
   
   [Конфиг Service]:https://github.com/flibook/devops-netology/blob/main/12-kubernetes-03-base-object-k8s/service.yaml <br />
   
### Правила приема работы

1. Домашняя работа оформляется в своем  Git репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода команд `kubectl get pods`, а также скриншот результата подключения
3. Репозиторий должен содержать файлы манифестов и ссылки на них в файле README.md

------

### Критерии оценки
Зачет - выполнены все задания, ответы даны в развернутой форме, приложены соответствующие скриншоты и файлы проекта, в выполненных заданиях нет противоречий и нарушения логики.

На доработку - задание выполнено частично или не выполнено, в логике выполнения заданий есть противоречия, существенные недостатки.
