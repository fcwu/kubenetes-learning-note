# Helm

- [Helm](#helm)
- [Kubernetes](#kubernetes)
  - [Deployment](#deployment)
    - [Service: Access from external cluster](#service-access-from-external-cluster)
  - [Ingress](#ingress)
  - [EndPoint](#endpoint)
  - [CNI](#cni)
  - [CSI](#csi)
    - [Volume SPEC](#volume-spec)
      - [emptyDir](#emptydir)
      - [hostPath](#hostpath)
      - [local](#local)
      - [nfs](#nfs)
      - [secret](#secret)
      - [configMap](#configmap)
  - [DNS](#dns)
  - [Tools](#tools)
  - [Reference](#reference)

```
helm search hub wordpress
helm show values stable/wordpress > values.yaml 
helm install wordpress stable/wordpress -f values.yaml
```

```
$ helm create mcs-lite-chart
$ helm install . --dry-run --debug
$ helm install . --name mcs-lite-chart
$ helm ls
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

- Kubeapps Hub v3: https://hub.kubeapps.com/
- Charts example: https://github.com/helm/helm/tree/master/cmd/helm/testdata/testcharts/alpine
- Charts v2 collection: https://github.com/helm/charts
- Helm Hub v2: https://hub.helm.sh/
