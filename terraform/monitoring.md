# Monitoring

## Prometheus

```bash
$ helm upgrade --namespace monitoring --create-namespace --install prometheus-1 stable/prometheus \
    --set server.global.scrape_interval=10s
```

## Grafana

```bash
$ k create secret generic grafana-admin \
    --from-literal=admin-user=dorowu \
    --from-literal=admin-password=dorowu \
    --namespace monitoring
$ helm upgrade --install grafana stable/grafana \
  --namespace monitoring \
  --set persistence.enabled=true \
  -f dashboards/provider.yaml \
  --set-file dashboards.default.default.json=dashboards/kubernetes.json \
  -f datasources/datasources.yaml \
  --set admin.existingSecret=grafana-admin \
  --set "grafana\.ini".server.domain=localhost \
  --set-string "grafana\.ini".server.root_url="%(protocol)s://%(domain)s:%(http_port)s/admin/grafana/" \
  --set "grafana\.ini".server.serve_from_sub_path=true
$ cat <<EOF | kubectl apply -f -
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
EOF
```
