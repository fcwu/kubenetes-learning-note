# Traefik

<!-- @import "[TOC]" {cmd="toc" depthFrom=2 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

- [Setup](#setup)
- [TLS](#tls)
- [Basic Authentication](#basic-authentication)
- [Name-based Routing](#name-based-routing)
- [Path-based Routing](#path-based-routing)
- [Multiple Ingress Definitions for the Same Host (or Host+Path)](#multiple-ingress-definitions-for-the-same-host-or-hostpath)
- [Routing Priority](#routing-priority)
- [Forwarding to ExternalNames](#forwarding-to-externalnames)
- [Disable passing the host header](#disable-passing-the-host-header)
- [Partitioning the Ingress object space](#partitioning-the-ingress-object-space)
- [Traffic Splitting](#traffic-splitting)
- [Production Advice](#production-advice)
- [Mirroring](#mirroring)

<!-- /code_chunk_output -->

![Ingress](assets/ingress.png)

## Setup

deploy can be one of

- DaemonSet: Suggestion. Efficient but less flexibility
- Deployment
- [Helm](https://github.com/kubernetes/charts/tree/master/stable/traefik)

create cluster

```bash
k apply -f https://raw.githubusercontent.com/containous/traefik/v1.7/examples/k8s/traefik-rbac.yaml
k apply -f https://raw.githubusercontent.com/containous/traefik/v1.7/examples/k8s/traefik-ds.yaml
k apply -f https://raw.githubusercontent.com/containous/traefik/v1.7/examples/k8s/ui.yaml
k port-forward ds/traefik-ingress-controller 11080:8080 --address 0.0.0.0 -n kube-system
curl http://127.0.0.1:11080
```

## TLS

add a TLS entrypoint by adding the following `args`

```bash
 --defaultentrypoints=http,https
 --entrypoints=Name:https Address::443 TLS
 --entrypoints=Name:http Address::80
```

add the TLS port either to the DaemonSet

```bash
ports:
- name: https
  containerPort: 443
  hostPort: 443
```

To setup an HTTPS-protected ingress, you can leverage the TLS feature of the ingress resource.

```bash
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: traefik-web-ui
  namespace: kube-system
  annotations:
    kubernetes.io/ingress.class: traefik
spec:
  rules:
  - host: traefik-ui.minikube
    http:
      paths:
      - backend:
          serviceName: traefik-web-ui
          servicePort: 80
  tls:
   - secretName: traefik-ui-tls-cert
```

Generate cert and key

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=traefik-ui.minikube"
kubectl -n kube-system create secret tls traefik-ui-tls-cert --key=tls.key --cert=tls.crt
```

The TLS certificates will be added to all entrypoints defined by the ingress annotation `traefik.frontend.entryPoints`. If no such annotation is provided, the TLS certificates will be added to all TLS-enabled `defaultEntryPoints`.

## Basic Authentication

```bash
htpasswd -c ./auth myusername
kubectl create secret generic mysecret --from-file auth --namespace=monitoring
```

Following is a full Ingress example based on Prometheus:

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
 name: prometheus-dashboard
 namespace: monitoring
 annotations:
   kubernetes.io/ingress.class: traefik
   traefik.ingress.kubernetes.io/auth-type: "basic"
   traefik.ingress.kubernetes.io/auth-secret: "mysecret"
spec:
 rules:
 - host: dashboard.prometheus.example.com
   http:
     paths:
     - backend:
         serviceName: prometheus
         servicePort: 9090
```

## Name-based Routing

checkout

- [cheese-deployments.yaml](example/traefik/cheese-deployments.yaml)
- [cheese-services.yaml](example/traefik/cheese-services.yaml)
- [cheese-ingress.yaml](example/traefik/cheese-ingress.yaml)

Set cluster FQDN

```bash
echo "10.0.0.10 stilicon.kubernetes cheddar.kubernetes wensleydale.kubernetes" | sudo tee -a /etc/hosts
```

## Path-based Routing

checkout

- [cheeses-ingress.yaml](example/traefik/cheeses-ingress.yaml)

## Multiple Ingress Definitions for the Same Host (or Host+Path)

## Routing Priority

## Forwarding to ExternalNames

## Disable passing the host header

## Partitioning the Ingress object space

## Traffic Splitting

## Production Advice

## Mirroring
