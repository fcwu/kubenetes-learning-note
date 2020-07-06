# Install and Configuration

https://cloud.google.com/kubernetes-engine/docs/quickstart

Run kubeadm init on the head node.

Create a network for IP-per-Pod criteria.

Run kubeadm join --token token head-node-IP on worker nodes.

    $ kubectl create -f https://git.io/weave-kube 

https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/

    Single-node
    With a single-node deployment, all the components run on the same server. This is great for testing, learning, and developing around Kubernetes.

    Single head node, multiple workers
    Adding more workers, a single head node and multiple workers typically will consist of a single node etcd instance running on the head node with the API, the scheduler, and the controller-manager.

    Multiple head nodes with HA, multiple workers
    Multiple head nodes in an HA configuration and multiple workers add more durability to the cluster. The API server will be fronted by a load balancer, the scheduler and the controller-manager will elect a leader (which is configured via flags). The etcd setup can still be single node.

    HA etcd, HA head nodes, multiple workers
    The most advanced and resilient setup would be an HA etcd cluster, with HA head nodes and multiple workers. Also, etcd would run as a true cluster, which would provide HA and would run on nodes separate from the Kubernetes head nodes.


cri-o container

    root@lfs458-node-1a0a: ̃# add-apt-repository ppa:projectatomic/ppa
    root@lfs458-node-1a0a: ̃# apt-get install -y cri-o-1.15
    root@lfs458-node-1a0a: ̃# vim /etc/crio/crio.conf


    apiVersion: kubeadm.k8s.io/v1beta2
    kind: ClusterConfiguration
    kubernetesVersion: 1.18.1               #<-- Use the word stable for newest version
    controlPlaneEndpoint: "k8smaster:6443"  #<-- Use the node alias not the IP
    networking:
    podSubnet: 192.168.0.0/16             #<-- Match the IP range from the Calico config file

    root@lfs458-node-1a0a: ̃# kubeadm init --config=kubeadm-config.yaml --upload-certs \
    | tee kubeadm-init.out      # Save output for future review

### create new token

    student@lfs458-node-1a0a: ̃$ sudo kubeadm token create
    27eee4.6e66ff60318da929

    openssl x509 -pubkey \
    -in /etc/kubernetes/pki/ca.crt | openssl rsa \
    -pubin -outform der 2>/dev/null | openssl dgst \
    -sha256 -hex | sed 's/ˆ.* //'

    (stdin)=  6d541678b05652e1fa5d43908e75e67376e994c3483d6683f2a18673e5d2a1b0

    root@lfs458-worker: ̃# kubeadm join \
    --token 27eee4.6e66ff60318da929 \
    k8smaster:6443 \
    --discovery-token-ca-cert-hash \
    sha256:6d541678b05652e1fa5d43908e75e67376e994c3483d6683f2a18673e5d2a1b0

### taint

```
student@lfs458-node-1a0a: ̃$ kubectl get node
student@lfs458-node-1a0a: ̃$ kubectl describe node lfs458-node-1a0a
student@lfs458-node-1a0a: ̃$ kubectl describe node | grep -i taint
student@lfs458-node-1a0a: ̃$ kubectl taint nodes --all node-role.kubernetes.io/master-
student@lfs458-node-1a0a: ̃$ kubectl describe node | grep -i taint
student@lfs458-node-1a0a: ̃$ kubectl taint nodes --all node.kubernetes.io/not-ready-
```

### app

```shell
student@lfs458-node-1a0a: ̃$ kubectl get deployments nginx --export -o yaml
student@lfs458-node-1a0a: ̃$ kubectl expose deployment/nginx
student@lfs458-node-1a0a: ̃$ kubectl scale deployment nginx --replicas=2
student@lfs458-node-1a0a: ̃$ kubectl expose deployment nginx --type=LoadBalancer
```

## K8s Arch

```yaml
ResourceQuota
resources:
  limits: 
    cpu: "1"
    memory: "4Gi" 
  requests:
    cpu: "0.5"
    memory: "500Mi"
```

A beta feature in v1.12 uses the `scopeSelector` field in the quota spec to run a pod at a specific priority if it has the appropriate `priorityClassName` in its pod spec.

![Screen Shot 2020-06-23 at 5.35.28 PM](/assets/Screen%20Shot%202020-06-23%20at%205.35.28%20PM.png)

### Node

If the kube-apiserver cannot communicate with the kubelet on a node for 5 minutes, the default NodeLease will schedule the node for deletion and the NodeStatus will change from ready. The pods will be evicted once a connection is re-established. They are no longer forcibly removed and rescheduled by the cluster.

Each node object exists in the kube-node-lease namespace. To remove a node from the cluster, first use kubectl delete node <node-name> to remove it from the API server. This will cause pods to be evacuated. Then, use kubeadm reset to remove cluster-specific information. 

pod

    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File

### resource limit by namespace

student@lfs458-node-1a0a: ̃$ kubectl get LimitRange --all-namespaces

```
apiVersion: v1
kind: LimitRange
metadata:
  name: mem-limit-range
spec:
  limits:
  - default:
      memory: 512Mi
    defaultRequest:
      memory: 256Mi
    type: Container
```

    kubectl apply -f https://k8s.io/examples/admin/resource/memory-defaults.yaml --namespace=default-mem-example

### scale

  student@lfs458-node-1a0a: ̃$ kubectl scale deployment maint --replicas=20
  student@lfs458-node-1a0a: ̃$ kubectl drain lfs458-worker
  student@lfs458-node-1a0a: ̃$ kubectl describe node |grep -i taint
  student@lfs458-node-1a0a: ̃$ kubectl drain lfs458-worker --ignore-daemonsets
  student@lfs458-node-1a0a: ̃$ kubectl drain lfs458-worker --ignore-daemonsets --delete-local-data
  student@lfs458-node-1a0a: ̃$ kubectl uncordon lfs458-worker

## API and Access

  curl https://10.144.48.106:6443/api/v1/namespaces/bob/pods --cacert k8s-ca.crt --cert bob-k8s-access.crt --key bob-k8s.key
  kubectl auth can-i create deployments
  kubectl auth can-i create deployments --as bob
  kubectl auth can-i create deployments --as bob -n bob
  > k auth can-i list pod --kubeconfig ./bob-k8s-config -n default
  yes
  > k auth can-i get pod --kubeconfig ./bob-k8s-config -n default
  no
  > k auth reconcile -f ../workload/job.yaml -n default --kubeconfig bob-k8s-config
  > k get pod etcd-master -o go-template='{{range $k, $v := .metadata.annotations}}{{printf "%v: %v\n" $k $v }}{{end}}'

### annotation

$ kubectl annotate pods --all description='Production Pods' -n prod 
$ kubectl annotate --overwrite pods description="Old Production Pods" -n prod 
$ kubectl annotate pods foo description- -n prod

### pod

> k run mypod --image=busybox --dry-run=client --port=80 -o yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: mypod
  name: mypod
spec:
  containers:
  - image: busybox
    name: mypod
    ports:
    - containerPort: 80
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always

$ kubectl --v=10 get pods firstpod

k config view --minify --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 -d > ca.crt
k config view --minify --raw -o jsonpath='{.users[0].user.client-certificate-data}' | base64 -d > client.crt
k config view --minify --raw -o jsonpath='{.users[0].user.client-key-data}' | base64 -d > client-key.pem

> cat ~/.kube/cache/discovery/10.144.48.106_6443/v1/serverresources.json | jq . | grep kind
  "kind": "APIResourceList",
      "kind": "Binding",
      "kind": "ComponentStatus",
      "kind": "ConfigMap",
      "kind": "Endpoints",
      "kind": "Event",
      "kind": "LimitRange",
      "kind": "Namespace",
      "kind": "Namespace",
      "kind": "Namespace",
      "kind": "Node",

## API Objects

### StatefulSet

```
kubectl scale sts web --replicas=5
kubectl patch sts web -p '{"spec":{"replicas":3}}'
kubectl patch statefulset web -p '{"spec":{"updateStrategy":{"type":"RollingUpdate"}}}'
kubectl patch statefulset web -p '{"spec":{"updateStrategy":{"type":"RollingUpdate","rollingUpdate":{"partition":2}}}}'
kubectl get pod web-2 --template '{{range $i, $c := .spec.containers}}{{$c.image}}{{end}}'
kubectl patch statefulset web -p '{"spec":{"updateStrategy":{"type":"RollingUpdate","rollingUpdate":{"partition":0}}}}'
for p in 0 1 2; do kubectl get pod "web-$p" --template '{{range $i, $c := .spec.containers}}{{$c.image}}{{end}}'; echo; done
kubectl delete statefulset web --cascade=false
export TOKEN=$(k get secret `k get secrets -n default | awk '$0 ~ /default/ {print $1}'` -n default -o template='{{.data.token}}')
curl https://10.144.48.106:6443 -H "Authorization: Bearer $TOKEN" -k
kubectl proxy --api-prefix=/ &
curl http://127.0.0.1:8001/api/
```

`--cascade=false` parameter to the command. This parameter tells Kubernetes to only delete the StatefulSet, and to not delete any of its Pods.

## Official Document v1.18

- Getting Started
  - Release notes and version skew
  - Learning environment
    - minikube
    - kind
  - Container runtime
  - Deployment tool
    - kubeadm
      - install
      - troubleshooting
      - single control-plane cluster
      - customize control-plane configuration
      - HA topology
      - create HA cluster
      - setup HA etcd
      - configure kubelet
      - self-hosting control plane
    - kops
    - kubespray
  - Turnkey solution
  - on-premises vms
  - windows in k8s
- concepts
  - overview
  - arch
    - node
    - control plane-node communication
    - controller
    - cloud provider
  - containers
    - images
    - environment
    - runtime class
    - container lifecycle hook
  - workload
    - pods
      - pods
      - lifecycle
      - init containers
      - preset
      - pod topology
      - disruption
      - ephemeral container
    - controllers
      - replicaset
      - replication controller
      - deployments
      - statefulset
      - daemonset
      - jobs
      - garbage collection
      - TTL controller for finished resource
      - CronJob
  - service, load balancing and networking
    - service
    - service topology
    - endpoint slices
    - dns for service
    - applications with services
    - ingress
    - ingress controller
    - network policy
    - /etc/hosts
    - ipv6
  - storage
    - volumes
    - persistent volumes
    - volume snapshot
    - csi volume cloning
    - storage class
    - volume snapshot classes
    - dynamic volume provisioning
    - node-specific volume limits
  - configuration
    - best practices
    - ConfigMaps
    - Secure
    - resource of containers
    - pod overhead
    - resource bin pack for extended resource
    - cluster access kubeconfig
    - pod priority and preemption
  - security
    - Cloud native security
    - pod security standard
  - policies
    - limit ranges
    - resource quota
    - pod security
  - scheduling and eviction
    - scheduler
    - taints and tolerance
    - Assigning Pods to Nodes
    - framework
    - performance
  - cluster administration
    - certificates
      - easyrsa, openssl, cfssl
    - cloud provider
    - managing resource
      - tips
    - cluster networking
    - log arch
      - sidecar
      - fluentd
    - metrics
    - garbage collection
    - proxy
    - api priority and fairness
    - addons
  - extending k8s
- tasks
  - Install Tools: Set up Kubernetes tools on your computer.
    - kubectl
    - minikube
  - Administer a Cluster: Learn common tasks for administering a cluster.
    - kubeadm
      - certificate management
      - upgrade
      - windows node
      - upgrad windows node
    - Memory, CPU, and API Resources
      - Default Memory Requests and Limits for a Namespace
      - Default CPU Requests and Limits for a Namespace
      - Minimum and Maximum Memory Constraints for a Namespace
      - Minimum and Maximum CPU Constraints for a Namespace
      - Memory and CPU Quotas for a Namespace
      - Pod Quota for a Namespace
    - Install a Network Policy Provider
      - Use Calico for NetworkPolicy
      - Use Cilium for NetworkPolicy
      - Use Kube-router for NetworkPolicy
      - Romana for NetworkPolicy
      - Weave Net for NetworkPolicy
    - Access Clusters Using the Kubernetes API
    - Access Services Running on Clusters
    - Advertise Extended Resources for a Node
    - Autoscale the DNS Service in a Cluster
    - Default StorageClass
    - Reclaim Policy of a PersistentVolume
    - Cloud Controller Manager Administration
    - Cluster Management
    - Out of Resource Handling
    - Configure Quotas for API Objects
    - Control CPU Management Policies on the Node
    - Control Topology Management Policies on a node
    - Customizing DNS Service
    - Debugging DNS Resolution
    - Declare Network Policy
    - Developing Cloud Controller Manager
    - Enabling EndpointSlices
    - Enabling Service Topology
    - Encrypting Secret Data at Rest
    - Guaranteed Scheduling For Critical Add-On Pods
    - IP Masquerade Agent User Guide
    - Limit Storage Consumption
    - Namespaces Walkthrough
    - Operating etcd clusters for Kubernetes
    - Reconfigure a Node's Kubelet in a Live Cluster
    - Reserve Compute Resources for System Daemons
    - Safely Drain a Node while Respecting the PodDisruptionBudget
    - Securing a Cluster
    - Set Kubelet parameters via a config file
    - Set up High-Availability Kubernetes Masters
    - Share a Cluster with Namespaces
    - Using a KMS provider for data encryption
    - Using CoreDNS for Service Discovery
    - Using NodeLocal DNSCache in Kubernetes clusters
    - Using sysctls in a Kubernetes Cluster
  - Configure Pods and Containers: Perform common configuration tasks for Pods and containers.
    - Assign Memory Resources to Containers and Pods
    - Assign CPU Resources to Containers and Pods
    - Configure GMSA for Windows Pods and containers
    - Configure RunAsUserName for Windows pods and containers
    - Configure Quality of Service for Pods
    - Assign Extended Resources to a Container
    - Configure a Pod to Use a Volume for Storage
    - Configure a Pod to Use a PersistentVolume for Storage
    - Configure a Pod to Use a Projected Volume for Storage
    - Configure a Security Context for a Pod or Container
    - Configure Service Accounts for Pods
    - Pull an Image from a Private Registry
    - Configure Liveness, Readiness and Startup Probes
    - Assign Pods to Nodes
    - Assign Pods to Nodes using Node Affinity
    - Configure Pod Initialization
    - Attach Handlers to Container Lifecycle Events
    - Configure a Pod to Use a ConfigMap
    - Share Process Namespace between Containers in a Pod
    - Create static Pods
    - Translate a Docker Compose File to Kubernetes Resources
  - Manage Kubernetes Objects: Declarative and imperative paradigms for interacting with the Kubernetes API.
    - Declarative Management of Kubernetes Objects Using Configuration Files
    - Declarative Management of Kubernetes Objects Using Kustomize
    - Managing Kubernetes Objects Using Imperative Commands
    - Imperative Management of Kubernetes Objects Using Configuration Files
    - Update API Objects in Place Using kubectl patch
  - Inject Data Into Applications: Specify configuration and other data for the Pods that run your workload.
    - Define a Command and Arguments for a Container
    - Define Environment Variables for a Container
    - Expose Pod Information to Containers Through Environment Variables
    - Expose Pod Information to Containers Through Files
    - Distribute Credentials Securely Using Secrets
    - Inject Information into Pods Using a PodPreset  
  - Run Applications: Run and manage both stateless and stateful applications.
    - Run a Stateless Application Using a Deployment
    - Run a Single-Instance Stateful Application
    - Run a Replicated Stateful Application
    - Scale a StatefulSet
    - Delete a StatefulSet
    - Force Delete StatefulSet Pods
    - Horizontal Pod Autoscaler
    - Horizontal Pod Autoscaler Walkthrough
    - Specifying a Disruption Budget for your Application  
  - Run Jobs: Run Jobs using parallel processing.
    - Running Automated Tasks with a CronJob
    - Parallel Processing using Expansions
    - Coarse Parallel Processing Using a Work Queu
    - Fine Parallel Processing Using a Work Queue  
  - Access Applications in a Cluster: Configure load balancing, port forwarding, or setup firewall or DNS configurations to access applications in a cluster.
    - Web UI (Dashboard)
    - Accessing Clusters
    - Configure Access to Multiple Clusters
    - Use Port Forwarding to Access Applications in a Cluster
    - Use a Service to Access an Application in a Cluster
    - Connect a Front End to a Back End Using a Service
    - Create an External Load Balancer
    - List All Container Images Running in a Cluster
    - Set up Ingress on Minikube with the NGINX Ingress Controller
    - Communicate Between Containers in the Same Pod Using a Shared Volume
    - Configure DNS for a Cluster  
  - Monitoring, Logging, and Debugging: Set up monitoring and logging to troubleshoot a cluster, or debug a containerized application.
    - Application Introspection and Debugging
    - Auditing
    - Auditing with Falco
    - Debug a StatefulSet
    - Debug Init Containers
    - Debug Pods and ReplicationControllers
    - Debug Running Pods
    - Debug Services
    - Debugging Kubernetes nodes with crictl
    - Determine the Reason for Pod Failure
    - Developing and debugging services locally
    - Events in Stackdriver
    - Get a Shell to a Running Container
    - Logging Using Elasticsearch and Kibana
    - Logging Using Stackdriver
    - Monitor Node Health
    - Resource metrics pipeline
    - Tools for Monitoring Resources
    - Troubleshoot Applications
    - Troubleshoot Clusters
    - Troubleshooting  
  - Extend Kubernetes: Understand advanced ways to adapt your Kubernetes cluster to the needs of your work environment.
  - TLS: Understand how to protect traffic within your cluster using Transport Layer Security (TLS).
  - Manage Cluster Daemons: Perform common tasks for managing a DaemonSet, such as performing a rolling update.
  - Service Catalog: Install the Service Catalog extension API.
  - Networking: Learn how to configure networking for your cluster.
  - Example Task Template
  - Extend kubectl with plugins: Extend kubectl by creating and installing kubectl plugins.
  - Manage HugePages: Configure and manage huge pages as a schedulable resource in a cluster.
  - Schedule GPUs: Configure and schedule GPUs for use as a resource by nodes in a cluster.
