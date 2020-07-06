# CKA

## Problems

### 列出環境內所有的pv 並以 name欄位排序（使用kubectl自帶排序功能）

```
kubectl get pv --sort-by=.metadata.name
```

### 列出指定pod的日誌中狀態為Error的行，並記錄在指定的檔案上

```
kubectl logs <podname> | grep bash > /opt/KUCC000xxx/KUCC000xxx.txt
```

### 列出k8s可用的節點，不包含不可排程的 和 NoReachable的節點，並把數字寫入到檔案裡

```
#笨方法，人工數
kubectl get nodes

#CheatSheet方法，應該還能優化JSONPATH
JSONPATH='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}' \
 && kubectl get nodes -o jsonpath="$JSONPATH" | grep "Ready=True"
k get no node3 -o template='{{.metadata.name}}:{{range $_, $v := .status.conditions}}{{if eq $v.type "Ready" }}{{printf "%s\n" $v}}{{end}}{{end}}'
kubectl get no -o=jsonpath='{range .items[*]}{.metadata.name}:{.spec.taints[?(.key=="node.kubernetes.io/unreachable")].effect}{"\n"}{end}'
```

### 建立一個pod名稱為nginx，並將其排程到節點為 disk=stat上

```
#我的操作,實際上從文件複製更快
kubectl run nginx --image=nginx --restart=Never --dry-run > 4.yaml
#增加對應引數
vi 4.yaml
kubectl apply -f 4.yaml

apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
  nodeSelector:
    disktype: ssd
```

### 提供一個pod的yaml，要求新增Init Container，Init Container的作用是建立一個空檔案，pod的Containers判斷檔案是否存在，不存在則退出

```
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: apline
    image: nginx
    command: ['sh', '-c', 'if [ ! -e "/opt/myfile" ];then exit; fi;']
    ###增加init Container####
  initContainers:
  - name: init
    image: busybox
    command: ['sh', '-c', 'touch /目錄/work;']
```

### 指定在名稱空間內建立一個pod名稱為test，內含四個指定的映象nginx、redis、memcached、busybox

```
kubectl run test --image=nginx --image=redis --image=memcached --image=buxybox --restart=Never -n <namespace>
```

### 建立一個pod名稱為test，映象為nginx，Volume名稱cache-volume為掛在在/data目錄下，且Volume是non-Persistent的

```
apiVersion: v1
kind: Pod
metadata:
  name: test
spec:
  containers:
  - image: nginx
    name: test-container
    volumeMounts:
    - mountPath: /cache
      name: cache-volume
  volumes:
  - name: cache-volume
    emptyDir: {}
```

### 列出Service名為test下的pod 並找出使用CPU使用率最高的一個，將pod名稱寫入檔案中

```
#使用-o wide 獲取service test的SELECTOR
kubectl get svc test -o wide
##獲取結果我就隨便造了
NAME              TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE       SELECTOR
test   ClusterIP   None         <none>        3306/TCP   50d       app=wordpress,tier=mysql

#獲取對應SELECTOR的pod使用率，找到最大那個寫入檔案中
kubectl top pod -l 'app=wordpress,tier=mysql'

k edit cm coredns -n kube-system
    health {
       lameduck 5s
    }
    hosts {
        10.0.0.10 master
        10.0.0.11 node1
        10.0.0.12 node2
        10.0.0.13 node3
        fallthrough
    }


k edit deploy metrics-server -n kube-system
find args and append
--kubelet-insecure-tls
```

### 建立一個Pod名稱為nginx-app，映象為nginx，並根據pod建立名為nginx-app的Service，type為NodePort

```
kubectl run nginx-app --image=nginx --restart=Never --port=80
k expose pod/nginx-app --port=80 --type=NodePort
```

### 建立一個nginx的Workload，保證其在每個節點上執行，注意不要覆蓋節點原有的Tolerations

```
k apply -f nginx-ds.yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  labels:
    run: nginx
  name: nginx
spec:
  selector:
    matchLabels:
      run: nginx
  template:
    metadata:
      labels:
        run: nginx
    spec:
      containers:
      - image: nginx
        name: nginx
        resources: {}
      restartPolicy: Always
```

### 將deployment為nginx-app的副本數從1變成4。

```
kubectl scale  --replicas=4 deployment nginx-app
```

### 建立nginx-app的deployment ，使用映象為nginx:1.11.0-alpine ,修改映象為1.11.3-alpine，並記錄升級，再使用回滾，將映象回滾至nginx:1.11.0-alpine

```
> cat nginx-deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-app
spec:
  selector:
    matchLabels:
      run: nginx-app
  template:
    metadata:
      labels:
        run: nginx-app
    spec:
      containers:
      - image: nginx:1.11.0-alpine
        name: nginx-app
        resources: {}
      dnsPolicy: ClusterFirst
      restartPolicy: Always
k set image deploy nginx-app nginx-app=nginx:1.11.3-alpine --record
kubectl rollout undo deployment nginx-app
kubectl rollout status -w deployment nginx-app
```

### 根據已有的一個nginx的pod、建立名為nginx的svc、並使用nslookup查找出service dns記錄，pod的dns記錄並分別寫入到指定的檔案中

```
k run -it netutil --image=alpine
```

### 建立Secret 名為mysecret，內含有password欄位，值為bob，然後 在pod1裡 使用ENV進行呼叫，Pod2裡使用Volume掛載在/data 下

```
k create secret generic mysecret --from-literal=hello=world
> cat nginx-secret.yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: nginx
  name: nginx-secret
spec:
  containers:
  - image: nginx
    name: nginx-secret
    volumeMounts:
    - name: foo
      mountPath: "/etc/foo"
      readOnly: true
  - image: alpine
    name: nginx-2
    command: ["env"]
    env:
      - name: SECRET_USERNAME
        valueFrom:
          secretKeyRef:
            name: mysecret
            key: hello
  restartPolicy: Never
  volumes:
  - name: foo
    secret:
      secretName: mysecret
```

### 使node1節點不可排程，並重新分配該節點上的pod

```
kubectl drain node node1  --ignore-daemonsets --delete-local-data
```

### 使用etcd 備份功能備份etcd（提供enpoints，ca、cert、key）

```
root@master:/etc/kubernetes/pki/etcd# ETCDCTL_API=3 etcdctl --endpoints https://localhost:2379/ --cacert=./ca.crt --cert=server.crt --key=server.key snapshot save ~/db
Snapshot saved at /home/vagrant/db
```

### 給出一個失聯節點的叢集，排查節點故障，要保證改動是永久的。

```
#檢視叢集狀態
kubectl get nodes
#檢視故障節點資訊
kubectl describe node node1

#Message顯示kubelet無法訪問（記不清了）
#進入故障節點
ssh node1

#檢視節點中的kubelet程序
ps -aux | grep kubelete
#沒找到kubelet程序，檢視kubelet服務狀態
systemctl status kubelet.service 
#kubelet服務沒啟動，啟動服務並觀察
systemctl start kubelet.service 
#啟動正常，enable服務
systemctl enable kubelet.service 

#回到考試節點並檢視狀態
exit

kubectl get nodes #正常
```

### 建立一個pv，型別是hostPath，位於/data中，大小1G，模式ReadOnlyMany

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv
spec:
  capacity:
    storage: 1Gi  
  accessModes:
    - ReadOnlyMany
  hostPath:
    path: /data
```

### 給出一個叢集，排查出叢集的故障

這道題沒空做完。kubectl get node顯示connection refuse，估計是apiserver的故障。

### 給出一個節點，完善kubelet配置檔案，要求使用systemd配置kubelet

這道題沒空做完，

### 給出一個叢集，將節點node1新增到叢集中，並使用TLS bootstrapping

這道題沒空做完，花費時間比較長，可惜了。

考點：TLS Bootstrapping

參考： TLS Bootstrapping 

## Scope

- https://jimmysong.io/kubernetes-handbook/appendix/about-cka-candidate.html

test bed

- 1 etcd, 1 master, 2 worker
- 1 etcd, 1 master, 1 worker
- 1 etcd, 1 base node none k8s cluster
- 1 etcd, 1 master, 1 base node

coverage

- Installation, Configuration & Validation 安装，配置和验证12%
  - 设计一个k8s 集群
  - 安装k8s master 和 nodes
  - 配置安全的集群通信
  - 配置高可用的k8s集群
  - 知道如何获取k8s的发行的二进制文件
  - 提供底层的基础措施来部署一个集群
  - 选择一个网络方案
  - 选择你的基础设施配置
  - 在你的集群上配置端对端的测试
  - 分析端对端测试结果
  - 运行节点的端对端测试
- Core Concepts 核心概念 19%
  - 理解k8s api原语
  - 理解k8s 架构
  - 理解services和其它网络相关原语
- Application Lifecycle Management 应用生命周期管理 8%
  - 理解Deployment， 并知道如何进行rolling update 和 rollback
  - 知道各种配置应用的方式
  - 知道如何为应用扩容
  - 理解基本的应用自愈相关的内容
- Networking 网络 11%
  - 理解在集群节点上配置网络
  - 理解pod的网络概念
  - 理解service networking
  - 部署和配置网络负载均衡器
  - 知道如何使用ingress 规则
  - 知道如何使用和配置cluster dns
  - 理解CNI
- Storage 存储 7%
  - 理解持久化卷（pv），并知道如何创建它们
  - 理解卷（volumes）的access mode
  - 理解持久化卷声明（pvc）的原语
  - 理解k8s的存储对象（kubernetes storage objects）
  - 知道如何为应用配置持久化存储
- Scheduling 调度 5%
  - 使用label选择器来调度pods
  - 理解Daemonset的角色
  - 理解resource limit 会如何影响pod 调度
  - 理解如何运行多个调度器， 以及如何配置pod使用它们
  - 不使用调度器， 手动调度一个pod
  - 查看和显示调度事件events
  - 知道如何配置kubernetes scheduler
- Security 安全 12%
  - 知道如何配置认证和授权
  - 理解k8s安全相关原语
  - 理解如何配置网络策略（network policies）
  - 配合使用镜像的安全性
  - 定义安全上下文
  - 安全的持久化保存键值
- Cluster Maintenance 集群维护 11%
  - 理解k8s的集群升级过程
  - 促进操作系统的升级
  - 补充备份和还原的方法论
- Logging / Monitoring 日志/监控 5%
  - 理解如何监控所有的集群组件
  - 理解如何监控应用
  - 管理集群组件日志
  - 管理应用日志
- Troubleshooting 问题排查 10%
  - 排查应用失败故障
  - 排查控制层（control panel）故障
  - 排查工作节点（work node）故障
  - 排查网络故障
