# Prometheus

## Environemnt

```bash
k create -f namespace.yml
```

## Install prometheus

```bash
$ export HELM_NAME=prometheus-1 NAMESPACE=monitoring
$ helm show values stable/prometheus > values.yaml
$ diff values.yaml <(helm show values stable/prometheus)
206d205
<     storageClass: "nfs-client"
603c602
<     scrape_interval: 10s
---
>     scrape_interval: 1m
609c608
<     evaluation_interval: 10s
---
>     evaluation_interval: 1m
769c768
<     size: 80Gi
---
>     size: 8Gi
778c777
<     storageClass: "nfs-client"
---
>     # storageClass: "-"
$ helm upgrade --install ${HELM_NAME} stable/prometheus \
  --namespace $NAMESPACE \
  --values values.yaml
Release "prometheus-1" does not exist. Installing it now.
coalesce.go:195: warning: destination for env is a table. Ignoring non-table value []
coalesce.go:195: warning: destination for env is a table. Ignoring non-table value []
NAME: prometheus-1
LAST DEPLOYED: Mon Jun  8 10:42:46 2020
NAMESPACE: monitoring
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The Prometheus server can be accessed via port 80 on the following DNS name from within your cluster:
prometheus-1-server.monitoring.svc.cluster.local


Get the Prometheus server URL by running these commands in the same shell:
  export POD_NAME=$(kubectl get pods --namespace monitoring -l "app=prometheus,component=server" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace monitoring port-forward $POD_NAME 9090


The Prometheus alertmanager can be accessed via port 80 on the following DNS name from within your cluster:
prometheus-1-alertmanager.monitoring.svc.cluster.local


Get the Alertmanager URL by running these commands in the same shell:
  export POD_NAME=$(kubectl get pods --namespace monitoring -l "app=prometheus,component=alertmanager" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace monitoring port-forward $POD_NAME 9093
#################################################################################
######   WARNING: Pod Security Policy has been moved to a global property.  #####
######            use .Values.podSecurityPolicy.enabled with pod-based      #####
######            annotations                                               #####
######            (e.g. .Values.nodeExporter.podSecurityPolicy.annotations) #####
#################################################################################


The Prometheus PushGateway can be accessed via port 9091 on the following DNS name from within your cluster:
prometheus-1-pushgateway.monitoring.svc.cluster.local


Get the PushGateway URL by running these commands in the same shell:
  export POD_NAME=$(kubectl get pods --namespace monitoring -l "app=prometheus,component=pushgateway" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace monitoring port-forward $POD_NAME 9091

For more information on running Prometheus, visit:
https://prometheus.io/
```

## Grafana

```bash
$ diff values.yaml <(helm show values stable/grafana)
208c208
<   storageClassName: nfs-client
---
>   # storageClassName: default
249c249
<   existingSecret: "grafana-admin"
---
>   existingSecret: ""
312,321c312,320
< # datasources: {}
< datasources:
<   datasources.yaml:
<     apiVersion: 1
<     datasources:
<     - name: Prometheus
<       type: prometheus
<       url: http://prometheus-1-server
<       access: proxy
<       isDefault: true
---
> datasources: {}
> #  datasources.yaml:
> #    apiVersion: 1
> #    datasources:
> #    - name: Prometheus
> #      type: prometheus
> #      url: http://prometheus-prometheus-server
> #      access: proxy
> #      isDefault: true
358,369d356
< dashboardProviders:
<   dashboardproviders.yaml:
<     apiVersion: 1
<     providers:
<     - name: 'default'
<       orgId: 1
<       folder: ''
<       type: file
<       disableDeletion: false
<       editable: true
<       options:
<         path: /var/lib/grafana/dashboards/default
377,380c364
< dashboards:
<   default:
<     kubernetes-cluster:
<       json: $RAW_JSON
---
> dashboards: {}
429,432d412
<   server:
<     domain: localhost
<     root_url: "%(protocol)s://%(domain)s:%(http_port)s/admin/grafana/"
<     serve_from_sub_path: true
$ k create secret generic grafana-admin \
    --from-literal=admin-user=dorowu \
    --from-literal=admin-password=dorowu \
    --namespace monitoring
$ helm upgrade --install grafana stable/grafana \
  --namespace monitoring \
  --values values.yaml --set-file dashboards.default.kubernetes-cluster.json=dashboards/kubernetes.json
$ cat >ingress.yaml <<EOL
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: grafana
  annotations:
    traefik.frontend.rule.type: PathPrefixStrip
spec:
  rules:
  - http:
      paths:
      - path: /admin/grafana
        backend:
          serviceName: grafana
          servicePort: 80
EOL
$ k create -f ingress.yaml -n monitoring
$ k port-forward ds/traefik-ingress-controller 11080:80 --address 0.0.0.0 -n kube-system
$ k rollout restart deployment grafana -n monitoring
```
