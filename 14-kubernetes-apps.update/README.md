# Домашнее задание к занятию "Обновление приложений"
"Обновление приложений"

### Цель задания

Выбрать и настроить стратегию обновления приложения.

### Чеклист готовности к домашнему заданию

1. Кластер k8s.

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Документация Updating a Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#updating-a-deployment)
2. [Статья про стратегии обновлений](https://habr.com/ru/companies/flant/articles/471620/)

-----

### Задание 1. Выбрать стратегию обновления приложения и описать ваш выбор.

1. Имеется приложение, состоящее из нескольких реплик, которое требуется обновить.
2. Ресурсы, выделенные для приложения ограничены, и нет возможности их увеличить.
3. Запас по ресурсам в менее загруженный момент времени составляет 20%.
4. Обновление мажорное, новые версии приложения не умеют работать со старыми.
5. Какую стратегию обновления выберете и почему?

#### Решение

Вариант 1. Выбираем наименее загруженое время. Если приложение протестировано, то, вероятно,можно использовать Rolling Update, с параметрами `maxSurge` `maxUnavailable` во избежание ситуации с нехваткой ресурсов. 
В этом случае, k8s постепенно заменит все поды без ущерба, а в сдучае проблем, можно откатится к предыдущему состоянию. Ну или, как вариант, использовать Canary Strategy также вместе `maxSurge` `maxUnavailable`.


### Задание 2. Обновить приложение.

1. Создать deployment приложения с контейнерами nginx и multitool. Версию nginx взять 1.19. Кол-во реплик - 5.
2. Обновить версию nginx в приложении до версии 1.20, сократив время обновления до минимума. Приложение должно быть доступно.
3. Попытаться обновить nginx до версии 1.28, приложение должно оставаться доступным.
4. Откатиться после неудачного обновления.

#### Решение

1. Создать deployment приложения с контейнерами nginx и multitool. Версию nginx взять 1.19. Кол-во реплик - 5.

- [deployments.yaml](conf/deployments.yaml)
- [svc.yaml](conf/svc.yaml)

```bash
$ kubectl apply -f conf/deployments.yaml 
deployment.apps/netology-deployment created

$ kubectl apply -f conf/svc.yaml 
service/mysvc created

$ kubectl get pod
NAME                                   READY   STATUS    RESTARTS   AGE
netology-deployment-768978d8d4-2v51c   2/2     Running   0          30m
netology-deployment-768978d8d4-8vjxd   2/2     Running   0          30m
netology-deployment-768978d8d4-8xdc4   2/2     Running   0          30m
netology-deployment-768978d8d4-ppsct   2/2     Running   0          30m
netology-deployment-768978d8d4-rx5j5   2/2     Running   0          30m

$ kubectl get svc
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
mysvc        ClusterIP   10.102.27.94     <none>        9001/TCP,9002/TCP   11m
```

```bash
$ kubectl get pod netology-deployment-66d67f955b-ppsct -o yaml
apiVersion: v1
kind: Pod
metadata:
  annotations:
    cni.projectcalico.org/containerID: 1ef6ff3cc07fb0cce2aae3f88ada1130c1f974f8fa30465b000ac775e8bc2972
    cni.projectcalico.org/podIP: 10.244.99.14/32
    cni.projectcalico.org/podIPs: 10.244.99.14/32
  creationTimestamp: "2023-08-23T11:35:38Z"
  generateName: netology-deployment-768978d8d4-
  labels:
    app: main
    pod-template-hash: 768978d8d4
  name: netology-deployment-768978d8d4-ppsct
  namespace: app
  ownerReferences:
  - apiVersion: apps/v1
    blockOwnerDeletion: true
    controller: true
    kind: ReplicaSet
    name: netology-deployment-768978d8d4
    uid: f2791991-7aeb-479d-989b-2aa7bdef7e69
  resourceVersion: "81397"
  uid: 2f4f75db-f710-431c-b4e7-973498036452
spec:
  containers:
  - image: nginx:1.28
    imagePullPolicy: IfNotPresent
    name: nginx
    ports:
    - containerPort: 80
      protocol: TCP
    resources: {}
    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File
    volumeMounts:
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: kube-api-access-mjw5v
      readOnly: true
  - env:
    - name: HTTP_PORT
      value: "8080"
    - name: HTTPS_PORT
      value: "11443"
    image: wbitt/network-multitool
    imagePullPolicy: Always
    name: network-multitool
    ports:
    - containerPort: 8080
      name: http-port
      protocol: TCP
    - containerPort: 11443
      name: https-port
      protocol: TCP
    resources:
      limits:
        cpu: 10m
        memory: 20Mi
      requests:
        cpu: 1m
        memory: 20Mi
    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File
    volumeMounts:
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: kube-api-access-mjw5v
      readOnly: true
  dnsPolicy: ClusterFirst
  enableServiceLinks: true
  nodeName: ip-10-0-8-249
  preemptionPolicy: PreemptLowerPriority
  priority: 0
  restartPolicy: Always
  schedulerName: default-scheduler
  securityContext: {}
  serviceAccount: default
  serviceAccountName: default
  terminationGracePeriodSeconds: 30
  tolerations:
  - effect: NoExecute
    key: node.kubernetes.io/not-ready
    operator: Exists
    tolerationSeconds: 300
  - effect: NoExecute
    key: node.kubernetes.io/unreachable
    operator: Exists
    tolerationSeconds: 300
  volumes:
  - name: kube-api-access-mjw5v
    projected:
      defaultMode: 420
      sources:
      - serviceAccountToken:
          expirationSeconds: 3607
          path: token
      - configMap:
          items:
          - key: ca.crt
            path: ca.crt
          name: kube-root-ca.crt
      - downwardAPI:
          items:
          - fieldRef:
              apiVersion: v1
              fieldPath: metadata.namespace
            path: namespace
status:
  conditions:
  - lastProbeTime: null
    lastTransitionTime: "2023-08-23T11:35:25Z"
    status: "True"
    type: Initialized
  - lastProbeTime: null
    lastTransitionTime: "2023-08-23T11:35:04Z"
    status: "True"
    type: Ready
  - lastProbeTime: null
    lastTransitionTime: "2023-08-23T11:35:38Z"
    status: "True"
    type: ContainersReady
  - lastProbeTime: null
    lastTransitionTime: "2023-08-23T11:35:04Z"
    status: "True"
    type: PodScheduled
  containerStatuses:
  - containerID: containerd://341a855566df499063ae2fad90d263a54923351e0c4823a5e52637ea34ac6d0
    image: docker.io/wbitt/network-multitool:latest
    imageID: docker.io/wbitt/network-multitool@sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
    lastState: {}
    name: network-multitool
    ready: true
    restartCount: 0
    started: true
    state:
      running:
        startedAt: "2023-08-23T11:35:19Z"
  - containerID: containerd://645d031a2476b2f7e1c4747459672e58beb187311db5f570bb09c48008f41b8
    image: docker.io/library/nginx:1.19
    imageID: docker.io/library/nginx@sha256:d8c59e8348e0c03f9d2105eed9791438f9aea9586381b79deadbc857eef89d78
    lastState: {}
    name: nginx
    ready: true
    restartCount: 0
    started: true
    state:
      running:
        startedAt: "2023-08-23T11:35:22Z"
  hostIP: 192.168.1.88
  phase: Running
  podIP: 10.1.128.235
  podIPs:
  - ip: 10.1.128.235
  qosClass: Burstable
  startTime: "2023-08-23T11:35:04Z"
```

1. Обновить версию nginx в приложении до версии 1.20, сократив время обновления до минимума. Приложение должно быть доступно.

Изменим в `deployment.yaml` параметр image: nginx:1.19 на 1.20. и добавим доступность

```yaml
strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
```

```bash
$ kubectl exec deployment/netology-deployment -- curl mysvc:9002
Defaulted container "nginx" out of: nginx, network-multitool
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   157  100   157    0     0   7476      0 --:--:-- --:--:-- --:--:--  7476
WBITT Network MultiTool (with NGINX) - netology-deployment-66d67f955b-wd76r - 10.1.128.239 - HTTP: 8080 , HTTPS: 11443 . (Formerly praqma/network-multitool)

$ kubectl apply -f conf/deployments.yaml 
deployment.apps/netology-deployment configured

$ kubectl get pod -o wide
NAME                                   READY   STATUS              RESTARTS   AGE   IP             NODE       NOMINATED NODE   READINESS GATES
netology-deployment-768978d8d4-2v51c   2/2     Running             0          52m   10.244.99.15  microk8s   <none>           <none>
netology-deployment-768978d8d4-8vjxd   2/2     Running             0          52m   10.244.99.28   microk8s   <none>           <none>
netology-deployment-7ef6c456a7-gdtdh   2/2     Running             0          51s   10.244.99.32   microk8s   <none>           <none>
netology-deployment-768978d8d4-8xdc4   2/2     Terminating         0          52m   10.244.99.29   microk8s   <none>           <none>
netology-deployment-7ef6c456a7-hvfdg   2/2     Running             0          53s   10.244.99.31   microk8s   <none>           <none>
netology-deployment-7ef6c456a7-dswgh   0/2     ContainerCreating   0          18s   <none>         microk8s   <none>           <none>
netology-deployment-768978d8d4-ppsct   2/2     Terminating         0          52m   10.244.99.14    microk8s   <none>           <none>

$ kubectl exec deployment/netology-deployment -- curl mysvc:9002
Defaulted container "nginx" out of: nginx, network-multitool
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0WBITT Network MultiTool (with NGINX) - netology-deployment-7ef6c456a7-gdtdh - 10.244.99.32 - HTTP: 8080 , HTTPS: 11443 . (Formerly praqma/network-multitool)
100   157  100   157    0     0   1286      0 --:--:-- --:--:-- --:--:--  1276
```


```bash
$ kubectl get pod -o wide
NAME                                   READY   STATUS    RESTARTS   AGE     IP             NODE       NOMINATED NODE   READINESS GATES
netology-deployment-7ef6c456a7-gdtdh   2/2     Running   0          3m2s    10.244.99.32   microk8s   <none>           <none>
netology-deployment-7ef6c456a7-hvfdg   2/2     Running   0          3m4s    10.244.99.31   microk8s   <none>           <none>
netology-deployment-7ef6c456a7-dswgh   2/2     Running   0          2m29s   10.244.99.33   microk8s   <none>           <none>
netology-deployment-7ef6c456a7-jsgff   2/2     Running   0          2m11s   10.244.99.51   microk8s   <none>           <none>
netology-deployment-7ef6c456a7-ldgdk   2/2     Running   0          2m2s    10.244.99.53   microk8s   <none>           <none>
```

Поды обновились, а приложение оставалось доступным через `mysvc`.

```bash
$ kubectl describe deployment netology-deployment
Name:                   netology-deployment
Namespace:              default
CreationTimestamp:      Mon, 23 August 2023 11:35:03 +0300
Labels:                 app=main
Annotations:            deployment.kubernetes.io/revision: 2
Selector:               app=main
Replicas:               5 desired | 5 updated | 5 total | 5 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  1 max unavailable, 1 max surge
Pod Template:
  Labels:  app=main
  Containers:
   nginx:
    Image:        nginx:1.20
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
   network-multitool:
    Image:       wbitt/network-multitool
    Ports:       8080/TCP, 11443/TCP
    Host Ports:  0/TCP, 0/TCP
    Limits:
      cpu:     10m
      memory:  20Mi
      HTTPS_PORT:  11443
    Mounts:        <none>
  Volumes:         <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   netology-deployment-7ef6c456a7 (5/5 replicas created)
Events:          <none>

$ kubectl get svc
Error: unknown command "пÑget" for "kubectl"
Run 'kubectl --help' for usage.
```

1. Попытаться обновить nginx до версии 1.28, приложение должно оставаться доступным.

Изменим в `deployment.yaml` image: nginx:1.19 на 1.28.

```bash
$ kubectl apply -f conf/deployments.yaml 
deployment.apps/netology-deployment configured
```

Получаем

```bash
$ kubectl get pod
NAME                                   READY   STATUS             RESTARTS   AGE
netology-deployment-7ef6c456a7-hvfdg   2/2     Running            0          15m
netology-deployment-7ef6c456a7-dswgh   2/2     Running            0          15m
netology-deployment-7ef6c456a7-jsgff   2/2     Running            0          12m
netology-deployment-7ef6c456a7-ldgdk   2/2     Running            0          12m
netology-deployment-6ajft6f3gh-cjgfe   1/2     ImagePullBackOff   0          73s
netology-deployment-6ajft6f3gh-6dkfb   1/2     ImagePullBackOff   0          73s
```

при этом

```bash
$ kubectl exec deployment/netology-deployment -- curl mysvc:9002
Defaulted container "nginx" out of: nginx, network-multitool
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   157  100   157    0     0   5607      0 --:--:-- --:--:-- --:--:--  6280
WBITT Network MultiTool (with NGINX) - netology-deployment-7ef6c456a7-dswgh - 10.244.99.33 - HTTP: 8080 , HTTPS: 11443 . (Formerly praqma/network-multitool)
```

1. Откатиться после неудачного обновления.

```bash
$ kubectl rollout status deployment netology-deployment
Waiting for deployment "netology-deployment" rollout to finish: 2 out of 5 new replicas have been updated...
```

```bash
$ kubectl rollout undo deployment netology-deployment
deployment.apps/netology-deployment rolled back

$ kubectl get pod
NAME                                   READY   STATUS    RESTARTS   AGE
netology-deployment-7ef6c456a7-hvfdg   2/2     Running   0          22m
netology-deployment-7ef6c456a7-dswgh   2/2     Running   0          22m
netology-deployment-7ef6c456a7-jsgff   2/2     Running   0          22m
netology-deployment-7ef6c456a7-ldgdk   2/2     Running   0          21m
netology-deployment-7ef6c456a7-ksffk   2/2     Running   0          15s
```

### Правила приема работы

1. Домашняя работа оформляется в своем Git репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд, а также скриншоты результатов
3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md