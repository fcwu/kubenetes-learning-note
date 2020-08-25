# Harbor

1. Install by HELM

    ```shell
    helm repo add harbor https://helm.goharbor.io
    helm install harbor1 harbor/harbor \
        --set expose.tls.enabled=false \
        --set expose.ingress.annotations."ingress\.kubernetes\.io/ssl-redirect"=false \
        --set expose.ingress.annotations."nginx\.ingress\.kubernetes\.io/ssl-redirect"=false \
        --set externalURL=http://harbor.svc.joplin.mycluster \
        --set expose.ingress.hosts.core=harbor.svc.joplin.mycluster \
        --set expose.ingress.hosts.notary=notary.svc.joplin.mycluster \
        --set registry.relativeurls=true
    ```

2. Update ingress

3. Import root CA certificate to docker client

```shell
    sudo mkdir -p /etc/docker/certs.d/harbor.svc.joplin.mycluster/
    sudo ln -s /usr/local/share/ca-certificates/k3s/ca.crt /etc/docker/certs.d/harbor.svc.joplin.mycluster/ca.crt
    docker login harbor.svc.joplin.mycluster -u admin -p Harbor12345
```

TODO

1. sign image
2. helm chart
3. repo sync

## Reference

- Stop harbor: `k scale --replicas=0 $(k get sts,deploy -l app=harbor -o=name | xargs)`
