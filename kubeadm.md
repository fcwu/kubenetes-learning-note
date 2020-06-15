# kubeadm

add master IPs

```bash
root@master:~# kubeadm config view > kubeadm-config.yaml
root@master:~# cat kubeadm-config.yaml 
apiServer:
  extraArgs:
    authorization-mode: Node,RBAC
  timeoutForControlPlane: 4m0s
  certSANs:
  - 10.144.48.106
  - 127.0.0.1
  - dorowu.office.com
  - 10.0.0.10
apiVersion: kubeadm.k8s.io/v1beta2
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controllerManager: {}
dns:
  type: CoreDNS
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: k8s.gcr.io
kind: ClusterConfiguration
kubernetesVersion: v1.18.3
networking:
  dnsDomain: cluster.local
  podSubnet: 10.244.0.0/16
  serviceSubnet: 10.96.0.0/12
scheduler: {}
root@master:~# # update certSANs
root@master:~# rm x509 -in /etc/kubernetes/pki/apiserver.*
root@master:~# kubeadm init phase certs apiserver --config kubeadm-config.yaml
root@master:~# docker restart `docker ps | grep k8s_kube-apiserver | awk '{print $1}'`
root@master:~# openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text
```