# cert-manager

1. Install by HELM

    ```shell
    helm repo add jetstack https://charts.jetstack.io
    kubectl create namespace cert-manager
    helm repo update
    helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v0.16.1 --set installCRDs=true
    ```

2. Generate root CA

    ```shell
    openssl req -x509 -sha256 -newkey rsa:2048 -keyout ca.key -out ca.crt -days 356 -nodes -subj '/CN=mycluster'
    ```

3. Import root CA to k3s secret

    ```shell
    k create secret generic ca-key-pair -n cert-manager --from-file=tls.crt=ca.crt --from-file=tls.key=ca.key
    ```

4. Create cert-manager CA issuer

    ```shell
    cat << EOF | k create -f -
    apiVersion: cert-manager.io/v1alpha2
    kind: ClusterIssuer
    metadata:
        name: ca-issuer
        namespace: cert-manager
    spec:
        ca:
            secretName: ca-key-pair
    EOF
    ```

5. Verify ca-issuer corrctness

    ```shell
    > k get issuers ca-issuer -n cert-manager
    NAME        READY   AGE
    ca-issuer   True    3m57s
    > k get issuers -A
    NAMESPACE      NAME        READY   AGE
    cert-manager   ca-issuer   True    4m3s
    ```

6. Create a certificate for harbor where domain is `harbor.svc.joplin.mycluster`

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

7. Add root CA as trust CA

    ```shell
    sudo mkdir /usr/local/share/ca-certificates/k3s
    sudo cp ca.crt /usr/local/share/ca-certificates/drbd-k3s/ca.crt
    sudo update-ca-certificates
    ```

## Reference

- Add certificate for Chrome: <https://kamarada.github.io/en/2018/10/30/how-to-install-website-certificates-on-linux/>
- cert-manager official document: <https://cert-manager.io/docs/>
