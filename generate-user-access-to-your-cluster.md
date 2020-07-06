# Granting User Access to Your Kubernetes Cluster

```bash
$ openssl req -new -newkey rsa:4096 -nodes -keyout bob-k8s.key -out bob-k8s.csr -subj "/CN=bob/O=devops"
$ # create following file
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: bob-k8s-access
spec:
  groups:
  - system:authenticated
  request: # replace with output from shell command: cat bob-k8s.csr | base64 | tr -d '\n'
  usages:
  - client auth
$ k create -f k8s-csr.yaml
$ k get csr
$ k certificate approve bob-k8s-access
$ k get csr bob-k8s-access -o jsonpath='{.status.certificate}' | base64 --decode > bob-k8s-access.crt
$ k config view -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' --raw | base64 --decode - > k8s-ca.crt
$ k config set-cluster $(kubectl config view -o jsonpath='{.clusters[0].name}') --server=$(kubectl config view -o jsonpath='{.clusters[0].cluster.server}') --certificate-authority=k8s-ca.crt --kubeconfig=bob-k8s-config --embed-certs
$ k config set-credentials bob --client-certificate=bob-k8s-access.crt --client-key=bob-k8s.key --embed-certs --kubeconfig=bob-k8s-config
$ k config set-context bob --cluster=$(kubectl config view -o jsonpath='{.clusters[0].name}') --namespace=bob --user=bob --kubeconfig=bob-k8s-config
$ k create ns bob
$ k label ns bob user=bob env=sandbox
$ k config use-context bob --kubeconfig=bob-k8s-config
$ kubectl version --kubeconfig=bob-k8s-config
Client Version: version.Info{Major:"1", Minor:"12", GitVersion:"v1.12.1", GitCommit:"4ed3216f3ec431b140b1d899130a69fc671678f4", GitTreeState:"clean", BuildDate:"2018-10-05T16:46:06Z", GoVersion:"go1.10.4", Compiler:"gc", Platform:"darwin/amd64"}
Server Version: version.Info{Major:"1", Minor:"12", GitVersion:"v1.12.1", GitCommit:"4ed3216f3ec431b140b1d899130a69fc671678f4", GitTreeState:"clean", BuildDate:"2018-10-05T16:36:14Z", GoVersion:"go1.10.4", Compiler:"gc", Platform:"linux/amd64"}
$ k create rolebinding bob-admin --namespace=bob --clusterrole=admin --user=bob
$ curl https://10.144.48.106:6443/api/v1/namespaces/bob/pods --cacert k8s-ca.crt --cert bob-k8s-access.crt --key bob-k8s.key
$ k access-matrix --sa demo-sa -n default
$ k access-matrix --as bob -n bob
NAME                                            LIST  CREATE  UPDATE  DELETE
bindings                                              ✖
configmaps                                      ✔     ✔       ✔       ✔
controllerrevisions.apps                        ✔     ✖       ✖       ✖
cronjobs.batch                                  ✔     ✔       ✔       ✔
daemonsets.apps                                 ✔     ✔       ✔       ✔
deployments.apps                                ✔     ✔       ✔       ✔
endpoints                                       ✔     ✔       ✔       ✔
endpointslices.discovery.k8s.io                 ✖     ✖       ✖       ✖
events                                          ✔     ✖       ✖       ✖
events.events.k8s.io                            ✖     ✖       ✖       ✖
horizontalpodautoscalers.autoscaling            ✔     ✔       ✔       ✔
ingresses.extensions                            ✔     ✔       ✔       ✔
ingresses.networking.k8s.io                     ✔     ✔       ✔       ✔
jobs.batch                                      ✔     ✔       ✔       ✔
leases.coordination.k8s.io                      ✖     ✖       ✖       ✖
limitranges                                     ✔     ✖       ✖       ✖
localsubjectaccessreviews.authorization.k8s.io        ✔
networkpolicies.networking.k8s.io               ✔     ✔       ✔       ✔
persistentvolumeclaims                          ✔     ✔       ✔       ✔
poddisruptionbudgets.policy                     ✔     ✔       ✔       ✔
pods                                            ✔     ✔       ✔       ✔
podtemplates                                    ✖     ✖       ✖       ✖
replicasets.apps                                ✔     ✔       ✔       ✔
replicationcontrollers                          ✔     ✔       ✔       ✔
resourcequotas                                  ✔     ✖       ✖       ✖
rolebindings.rbac.authorization.k8s.io          ✔     ✔       ✔       ✔
roles.rbac.authorization.k8s.io                 ✔     ✔       ✔       ✔
secrets                                         ✔     ✔       ✔       ✔
serviceaccounts                                 ✔     ✔       ✔       ✔
services                                        ✔     ✔       ✔       ✔
statefulsets.apps                               ✔     ✔       ✔       ✔

```