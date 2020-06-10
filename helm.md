# Helm

<!-- @import "[TOC]" {cmd="toc" depthFrom=2 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

- [使用一個現有 Helm Chart](#使用一個現有-helm-chart)
- [Chart 的運作方式](#chart-的運作方式)
- [如何建立自己的 Chart](#如何建立自己的-chart)
- [Official site](#official-site)
- [repository](#repository)
- [Reference](#reference)

<!-- /code_chunk_output -->


## 使用一個現有 Helm Chart

```
sudo snap install helm --classic
helm search hub wordpress
helm show values stable/wordpress > values.yaml 
helm install wordpress stable/wordpress -f values.yaml
```

```
$ helm create mcs-lite-chart
$ helm install . --dry-run --debug
$ helm install . --name mcs-lite-chart
$ helm list
$ helm upgrade mcs-lite-app .
$ helm rollback mcs-lite-app 1
$ helm package . --debug -d ./charts
$ helm install ./charts/mcs-lite-chart-0.1.0.tgz
```

helm 3

```
helm repo add stable https://kubernetes-charts.storage.googleapis.com
helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com

```

## Chart 的運作方式

```bash
$ helm create helm-demo
$ tree helm-demo
.
├── Chart.yaml
├── charts
├── templates
│   ├── deployment.yaml
│   ├── ingress.yaml
│   └── service.yaml
└── values.yaml
```

- Chart.yaml: 定義了這個 Chart 的 Metadata，包括 Chart 的版本、名稱、敘述等
- charts: 在這個資料夾裡可以放其他的 Chart，這裡稱作 SubCharts
- templates: 定義這個 Chart 服務需要的 Kubernetes 元件。但我們並不會把各元件的參數寫死在裡面，而是會用參數的方式代入
- values.yaml: 定義這個 Chart 的所有參數，這些參數都會被代入在 templates 中的元件。例如我們會在這邊定義 nodePorts 給 service.yaml 、定義 replicaCount 給 deployment.yaml、定義 hosts 給 ingress.yaml 等等

## 如何建立自己的 Chart

Checkout [helm/demo](helm/demo)

Install
 
```bash
$ helm install .
NAME:   gilded-peacoc
LAST DEPLOYED: Mon May  6 16:31:27 2019
NAMESPACE: default
STATUS: DEPLOYED
RESOURCES:
==> v1/Deployment
NAME                      READY  UP-TO-DATE  AVAILABLE  AGE
gilded-peacock-helm-demo  0/2    2           0          0s
==> v1/Pod(related)
NAME                                READY STATUS          RESTARTS
gilded-peacock-helm-demo-5fc5964759 0/1   ContainerCreating  0        
gilded-peacock-helm-demo-5fc5964759 0/1   ContainerCreating  0        
==> v1/Service
NAME                      TYPE      CLUSTER-IP     EXTERNAL-IP  PORT(S)       
gilded-peacock-helm-demo  NodePort  10.106.164.53  <none>       80:30333/TCP
==> v1beta1/Ingress
NAME                      HOSTS          ADDRESS  PORTS
gilded-peacock-helm-demo  blue.demo.com  80       0s
NOTES:
1. Get the application URL by running these commands:
  http://blue.demo.com/
```

More commands

```bash
helm delete --purge RELEASE_NAME
helm upgrade RELEASE_NAME CHART_PATH
helm lint CHART_PATH
helm package CHART_PATH
```

## Official site

https://helm.sh/docs/chart_best_practices/values/

## repository

https://helm.sh/docs/topics/chart_repository/

## Reference

- easy start: https://medium.com/@C.W.Hu/kubernetes-helm-chart-tutorial-fbdad62a8b61
- Kubeapps Hub v3: https://hub.kubeapps.com/
- Charts example: https://github.com/helm/helm/tree/master/cmd/helm/testdata/testcharts/alpine
- Charts v2 collection: https://github.com/helm/charts
- Helm Hub v2: https://hub.helm.sh/
