# cert-manager

1. Install by HELM

    ```shell
    helm repo add jetstack https://charts.jetstack.io
    helm upgrade --install cert-manager1 jetstack/cert-manager --namespace cert-manager --version v0.16.1 --set installCRDs=true --create-namespace
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
    > k get clusterissuers ca-issuer -o wide
    NAME        READY   STATUS                AGE
    ca-issuer   True    Signing CA verified   46s

6. Add root CA as trust CA

    ```shell
    sudo mkdir /usr/local/share/ca-certificates/k3s
    sudo cp ca.crt /usr/local/share/ca-certificates/k3s/ca.crt
    sudo update-ca-certificates
    ```

[harbor.md] to create your first certificate.

## Reference

- Add certificate for Chrome: <https://kamarada.github.io/en/2018/10/30/how-to-install-website-certificates-on-linux/>
- cert-manager official document: <https://cert-manager.io/docs/>
