# Harbor

1. Install by HELM

    ```shell
    helm repo add harbor https://helm.goharbor.io
    k create ns harbor
    helm upgrade --install harbor1 harbor/harbor \
        -n harbor \
        --set expose.tls.enabled=false \
        --set-string expose.ingress.annotations."ingress\.kubernetes\.io/ssl-redirect"=false \
        --set-string expose.ingress.annotations."nginx\.ingress\.kubernetes\.io/ssl-redirect"=false \
        --set externalURL=http://harbor.svc.joplin.mycluster \
        --set expose.ingress.hosts.core=harbor.svc.joplin.mycluster \
        --set expose.ingress.hosts.notary=notary.svc.joplin.mycluster \
        --set registry.relativeurls=true
    ```

2. Create a certificate for harbor where domain is `harbor.svc.joplin.mycluster`

    ```shell
    export NAME=harbor DOMAIN=harbor.svc.joplin.mycluster NAMESPACE=harbor
    cat << EOF | k create -f -
    apiVersion: cert-manager.io/v1alpha2
    kind: Certificate
    metadata:
        name: ${NAME}-cert
        namespace: ${NAMESPACE}
    spec:
        commonName: ${DOMAIN}
        secretName: ${DOMAIN}-cert
        issuerRef:
            name: ca-issuer
            kind: ClusterIssuer
        dnsNames:
        - ${DOMAIN}
    EOF
    ```

3. Update ingress. Add tls section

    ```shell
    > k get ingress harbor1-harbor-ingress -n harbor -o yaml
    ...
    spec:
    rules:
        ...
    tls:
    - hosts:
        - harbor.svc.joplin.mycluster
        secretName: harbor.svc.joplin.mycluster-cert
    ...
    ```

4. Import root CA certificate to docker client

    ```shell
    sudo mkdir -p /etc/docker/certs.d/harbor.svc.joplin.mycluster/
    sudo ln -s /usr/local/share/ca-certificates/k3s/ca.crt /etc/docker/certs.d/harbor.svc.joplin.mycluster/ca.crt
    docker login harbor.svc.joplin.mycluster -u admin -p Harbor12345
    ```

5. Try to push image

    ```shell
    > docker tag ubuntu:20.04 harbor.svc.joplin.mycluster/library/ubuntu:20.04
    > docker push harbor.svc.joplin.mycluster/library/ubuntu:20.04
    The push refers to repository [harbor.svc.joplin.mycluster/library/ubuntu]
    8891751e0a17: Pushed
    2a19bd70fcd4: Pushed
    9e53fd489559: Pushed
    7789f1a3d4e9: Pushed
    20.04: digest: sha256:5747316366b8cc9e3021cd7286f42b2d6d81e3d743e2ab571f55bcd5df788cc8 size: 1152
    ```

TODO

1. sign image
2. helm chart
3. repo sync

## Troubleshooting

`pod/harbor1-harbor-database-0` may time out when initialize. You may extend initialDelaySeconds

```shell
> k get statefulset.apps/harbor1-harbor-database -n harbor -o yaml | grep -A 3 -B 3 ' initialDelaySeconds'
            command:
            - /docker-healthcheck.sh
          failureThreshold: 3
          initialDelaySeconds: 1200
          periodSeconds: 10
          successThreshold: 1
          timeoutSeconds: 1
```

## Reference

- Stop harbor: `k scale --replicas=0 $(k get sts,deploy -l app=harbor -o=name | xargs)`
- Debug values.yaml: `helm -n <namespace> get values <release-name>`
