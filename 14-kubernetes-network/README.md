# Домашнее задание к занятию "Как работает сеть в K8S"
Как работает сеть в K8S

### Цель задания

Настроить сетевую политику доступа к подам.

### Чеклист готовности к домашнему заданию

1. Кластер k8s с установленным сетевым плагином calico

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Документация Calico](https://www.tigera.io/project-calico/)
2. [Network Policy](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
3. [About Network Policy](https://docs.projectcalico.org/about/about-network-policy)

-----

### Задание 1. Создать сетевую политику (или несколько политик) для обеспечения доступа

1. Создать deployment'ы приложений frontend, backend и cache и соответствующие сервисы.
2. В качестве образа использовать network-multitool.
3. Разместить поды в namespace app.
4. Создать политики, чтобы обеспечить доступ frontend -> backend -> cache. Другие виды подключений должны быть запрещены.
5. Продемонстрировать, что трафик разрешен и запрещен.

### Решение

Манифесты
 - [Frontend](conf/main/10-frontend.yaml)
 
 - [Backend](conf/main/20-backend.yaml)

 - [Cache](conf/main/30-cache.yaml)

Создаем namespace
```bash
root@ip-10-0-6-123:~/main# kubectl create namespace app
namespace/app created
root@ip-10-0-6-123:~/main# kubectl get namespace
NAME              STATUS   AGE
app               Active   42s
default           Active   25h
kube-node-lease   Active   25h
kube-public       Active   25h
kube-system       Active   25h
```

Создаем deployment и svc
```bash
root@ip-10-0-6-123:~/main# kubectl apply -f conf/main/10-frontend.yaml 
deployment.apps/frontend created
service/frontend created
root@ip-10-0-6-123:~/main# kubectl apply -f conf/main/20-backend.yaml 
deployment.apps/backend created
service/backend created
root@ip-10-0-6-123:~/main# kubectl apply -f conf/main/30-cache.yaml 
deployment.apps/cache created
service/cache created

root@ip-10-0-6-123:~/main# kubectl get -n app deployments
NAME       READY   UP-TO-DATE   AVAILABLE   AGE
backend    1/1     1            1           29s
cache      1/1     1            1           19s
frontend   1/1     1            1           45s

root@ip-10-0-6-123:~/main# kubectl config set-context --current --namespace=app

root@ip-10-0-6-123:~/main# kubectl get pod -o wide
NAME                        READY   STATUS    RESTARTS   AGE   IP               NODE      NOMINATED NODE   READINESS GATES
backend-6478c64696-jrkcg    1/1     Running   0          6m   10.244.144.131    worker3   <none>           <none>         
cache-575bd6d866-sw7mg      1/1     Running   0          6m   10.244.100.131    worker2   <none>           <none>         
frontend-7c96b4cbfb-kv14d   1/1     Running   0          6m   10.244.41.3       worker1   <none>           <none>

root@ip-10-0-6-123:~/main# kubectl get svc -o wide
NAME       TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE   SELECTOR    
backend    ClusterIP   10.107.232.213  <none>        80/TCP    13m   app=backend 
cache      ClusterIP   10.108.179.184  <none>        80/TCP    13m   app=cache   
frontend   ClusterIP   10.107.180.6    <none>        80/TCP    13m   app=frontend
```

Проверяем доступность сервисов

```bash
root@ip-10-0-6-123:~/main# kubectl exec frontend-7c96b4cbfb-kv14d -- curl backend
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed  
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0Praqma Network MultiTool (with NGINX) - backend-6478c64696-jrkcg - 10.244.144.131
100    79  100    79    0     0  14319      0 --:--:-- --:--:-- --:--:-- 15800                                                                              
root@ip-10-0-6-123:~/main# kubectl exec frontend-7c96b4cbfb-kv14d -- curl cache
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0Praqma Network MultiTool (with NGINX) - cache-575bd6d866-sw7mg - 10.244.100.131
100    78  100    78    0     0   9364      0 --:--:-- --:--:-- --:--:--  9750
root@ip-10-0-6-123:~/main# kubectl exec cache-575bd6d866-sw7mg -- curl frontend
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    83  100    83    0     0  13847      0 --:--:-- --:--:-- --:--:-- 16600
Praqma Network MultiTool (with NGINX) - frontend-7c96b4cbfb-kv14d - 10.244.41.3 
```

Сетевые политики:
 - [NP-Default](conf/network-policy/00-default.yaml)

 - [NP-Backend](conf/network-policy/20-backend.yaml)
 
 - [NP-Cache](conf/network-policy/30-cache.yaml)

Запрещающее правило.
```bash
root@ip-10-0-6-123:~/main# kubectl apply -f conf/network-policy/00-default.yaml 
networkpolicy.networking.k8s.io/default-deny-ingress created
root@ip-10-0-6-123:~/main# kubectl exec frontend-7c96b4cbfb-kv14d -- curl cache
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:02:05 --:--:--     0
curl: (28) Failed to connect to cache port 80 after 125753 ms: Operation timed out
command terminated with exit code 28

```

Разрешающие правила:

```bash

root@ip-10-0-6-123:~/main# kubectl apply -f conf/network-policy/20-backend.yaml 
networkpolicy.networking.k8s.io/backend created
root@ip-10-0-6-123:~/main# kubectl apply -f conf/network-policy/30-cache.yaml 
networkpolicy.networking.k8s.io/cache created

root@ip-10-0-6-123:~/main# kubectl get networkpolicy
NAME                   POD-SELECTOR   AGE
backend                app=backend    13m
cache                  app=cache      13m
default-deny-ingress   <none>         17m
frontend               app=frontend   13m
```

Проверяем 

```bash
root@ip-10-0-6-123:~/main# kubectl exec frontend-7c96b4cbfb-kv14d -- curl --max-time 10 backend
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    79  100    79    0     0   6779      0 --:--:-- --:--:-- --:--:--  7181
Praqma Network MultiTool (with NGINX) - backend-6478c64696-jrkcg - 10.244.144.131
root@ip-10-0-6-123:~/main# kubectl exec frontend-7c96b4cbfb-kv14d -- curl --max-time 10 cache
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:10 --:--:--     0
curl: (28) Connection timed out after 10000 milliseconds
command terminated with exit code 28

root@ip-10-0-6-123:~/main# kubectl exec backend-6478c64696-jrkcg -- curl --max-time 10 cache
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    78  100    78    0     0  11787      0 --:--:-- --:--:-- --:--:-- 13000
Praqma Network MultiTool (with NGINX) - cache-575bd6d866-sw7mg - 10.244.100.131
root@ip-10-0-6-123:~/main# kubectl exec backend-6478c64696-jrkcg -- curl --max-time 10 frontend
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:11 --:--:--     0
curl: (28) Connection timed out after 10000 milliseconds
command terminated with exit code 28

root@ip-10-0-6-123:~# kubectl exec cache-575bd6d866-sw7mg -- curl --max-time 10 frontend
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:11 --:--:--     0
curl: (28) Connection timed out after 10001 milliseconds
command terminated with exit code 28
root@ip-10-0-6-123:~# kubectl exec cache-575bd6d866-sw7mg -- curl --max-time 10 backend
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:11 --:--:--     0
curl: (28) Connection timed out after 10001 milliseconds
command terminated with exit code 28
```

### Правила приема работы

1. Домашняя работа оформляется в своем Git репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд, а также скриншоты результатов
3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md