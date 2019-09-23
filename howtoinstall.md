01.base env
=============

아래 순서대로 작업을 수행함

- HOST

~~~
git clone https://github.com/osci-khoj/kubernetes-the-hard-way-centos.git

cd kubernetes-the-hard-way-centos/vagrant

vagrant up
~~~

10분 정도 기다림 (화면 주목)


02.vagrant 내 접근허용
===========

(반드시 kubernetes-the-hard-way-centos/vagrant 그 위치에서 수행)

- HOST

~~~
vagrant status

vagrant ssh master-1
~~~

- master-1

~~~
ssh-keygen` password: vagrant

ssh-copy-id master-2

ssh-copy-id worker-1

ssh-copy-id worker-2

ssh-copy-id lb

wget https://storage.googleapis.com/kubernetes-release/release/v1.15.4/bin/linux/amd64/kubectl

chmod +x kubectl

sudo mv kubectl /usr/local/bin/

~~~


03.CA프로비저닝 및 TLS 인증서 생성
==========

- CA 인증서

~~~~
openssl genrsa -out ca.key 2048
openssl req -new -key ca.key -subj "/CN=KUBERNETES-CA" -out ca.csr
openssl x509 -req -in ca.csr -signkey ca.key -CAcreateserial  -out ca.crt -days 1000
~~~~

- admin 인증서

~~~
openssl genrsa -out admin.key 2048
openssl req -new -key admin.key -subj "/CN=admin/O=system:masters" -out admin.csr
openssl x509 -req -in admin.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out admin.crt -days 1000
~~~

- Controller Manager 인증서

~~~
openssl genrsa -out kube-controller-manager.key 2048
openssl req -new -key kube-controller-manager.key -subj "/CN=system:kube-controller-manager" -out kube-controller-manager.csr
openssl x509 -req -in kube-controller-manager.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out kube-controller-manager.crt -days 1000
~~~

- kube proxy 인증서

~~~    
openssl genrsa -out kube-proxy.key 2048
openssl req -new -key kube-proxy.key -subj "/CN=system:kube-proxy" -out kube-proxy.csr
openssl x509 -req -in kube-proxy.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out kube-proxy.crt -days 1000
~~~

- Scheduler 인증서

~~~
openssl genrsa -out kube-scheduler.key 2048
openssl req -new -key kube-scheduler.key -subj "/CN=system:kube-scheduler" -out kube-scheduler.csr
openssl x509 -req -in kube-scheduler.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out kube-scheduler.crt -days 1000
~~~

- API Server 인증서

~~~
cat> openssl.cnf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster.local
IP.1 = 10.96.0.1
IP.2 = 192.168.25.11
IP.3 = 192.168.25.12
IP.4 = 192.168.25.30
IP.5 = 127.0.0.1
EOF
~~~
~~~
openssl genrsa -out kube-apiserver.key 2048
openssl req -new -key kube-apiserver.key -subj "/CN=kube-apiserver" -out kube-apiserver.csr -config openssl.cnf
openssl x509 -req -in kube-apiserver.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out kube-apiserver.crt -extensions v3_req -extfile openssl.cnf -days 1000
~~~

- ETCD 인증

~~~
cat> openssl-etcd.cnf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
IP.1 = 192.168.25.11
IP.2 = 192.168.25.12
IP.3 = 127.0.0.1
EOF
~~~
~~~
openssl genrsa -out etcd-server.key 2048
openssl req -new -key etcd-server.key -subj "/CN=etcd-server" -out etcd-server.csr -config openssl-etcd.cnf
openssl x509 -req -in etcd-server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out etcd-server.crt -extensions v3_req -extfile openssl-etcd.cnf -days 1000
~~~

- service account 인증서

~~~
openssl genrsa -out service-account.key 2048
openssl req -new -key service-account.key -subj "/CN=service-accounts" -out service-account.csr
openssl x509 -req -in service-account.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out service-account.crt -days 1000
~~~

- 인증서 배포

~~~
for instance in master-2; do
scp ca.crt ca.key kube-apiserver.key kube-apiserver.crt \
service-account.key service-account.crt \
etcd-server.key etcd-server.crt \
${instance}:~/
 done
~~~

05.구성파일 배포
========

- master-1

~~~
LOADBALANCER_ADDRESS=192.168.25.30
~~~
- master-1 / kube-proxy kubeconfig 파일 -
~~~
  kubectl config set-cluster kubernetes-the-hard-way \
    certificate-authority=ca.crt \
    embed-certs=true \
    server=https://${LOADBALANCER_ADDRESS}:6443 \
    kubeconfig=kube-proxy.kubeconfig

  kubectl config set-credentials system:kube-proxy \
    client-certificate=kube-proxy.crt \
    client-key=kube-proxy.key \
    embed-certs=true \
    kubeconfig=kube-proxy.kubeconfig

  kubectl config set-context default \
    cluster=kubernetes-the-hard-way \
    user=system:kube-proxy \
    kubeconfig=kube-proxy.kubeconfig

  kubectl config use-context default kubeconfig=kube-proxy.kubeconfig
~~~


- master-1 / kube-controller-manager kubeconfig 파일-


~~~
  kubectl config set-cluster kubernetes-the-hard-way \
    certificate-authority=ca.crt \
    embed-certs=true \
    server=https://127.0.0.1:6443 \
    kubeconfig=kube-controller-manager.kubeconfig

  kubectl config set-credentials system:kube-controller-manager \
    client-certificate=kube-controller-manager.crt \
    client-key=kube-controller-manager.key \
    embed-certs=true \
    kubeconfig=kube-controller-manager.kubeconfig

  kubectl config set-context default \
    cluster=kubernetes-the-hard-way \
    user=system:kube-controller-manager \
    kubeconfig=kube-controller-manager.kubeconfig

  kubectl config use-context default kubeconfig=kube-controller-manager.kubeconfig
~~~

- master-1 / kube-scheduler kubeconfig 파일

~~~
  kubectl config set-cluster kubernetes-the-hard-way \
    certificate-authority=ca.crt \
    embed-certs=true \
    server=https://127.0.0.1:6443 \
    kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-credentials system:kube-scheduler \
    client-certificate=kube-scheduler.crt \
    client-key=kube-scheduler.key \
    embed-certs=true \
    kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-context default \
    cluster=kubernetes-the-hard-way \
    user=system:kube-scheduler \
    kubeconfig=kube-scheduler.kubeconfig

  kubectl config use-context default kubeconfig=kube-scheduler.kubeconfig
~~~

- masgter-1 / admin kubeconfig 파일

~~~
  kubectl config set-cluster kubernetes-the-hard-way \
    certificate-authority=ca.crt \
    embed-certs=true \
    server=https://127.0.0.1:6443 \
    kubeconfig=admin.kubeconfig

  kubectl config set-credentials admin \
    client-certificate=admin.crt \
    client-key=admin.key \
    embed-certs=true \
    kubeconfig=admin.kubeconfig

  kubectl config set-context default \
    cluster=kubernetes-the-hard-way \
    user=admin \
    kubeconfig=admin.kubeconfig

  kubectl config use-context default kubeconfig=admin.kubeconfig
~~~

- master-1 / master에 배포

~~~
for instance in  master-2; do
  scp admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig ${instance}:~/
done
~~~

- master-1 / worker에 배포

~~~
for instance in worker-1 worker-2; do
  scp kube-proxy.kubeconfig ${instance}:~/
done
~~~

06.Data 암호화
===

- master-1

~~~
ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
~~~
~~~
cat> encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF
~~~
~~~
for instance in master-2; do
scp encryption-config.yaml ${instance}:~/
done
~~~

07.etcd 클러스터 구성
===

- master-1/master-2

~~~
wget https://github.com/etcd-io/etcd/releases/download/v3.4.0/etcd-v3.4.0-linux-amd64.tar.gz
tar -xvf etcd-v3.4.0-linux-amd64.tar.gz
sudo mv etcd-v3.4.0-linux-amd64/etcd* /usr/local/bin
sudo mkdir -p /etc/etcd /var/lib/etcd
sudo cp ca.crt etcd-server.key etcd-server.crt /etc/etcd/
INTERNAL_IP=$(ip addr show eth1 | grep "inet " | awk '{print $2}' | cut -d / -f 1)
ETCD_NAME=$(hostname -s)
~~~
~~~
cat <<EOF | sudo tee /etc/systemd/system/etcd.service
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
ExecStart=/usr/local/bin/etcd \\
  name ${ETCD_NAME} \\
  cert-file=/etc/etcd/etcd-server.crt \\
  key-file=/etc/etcd/etcd-server.key \\
  peer-cert-file=/etc/etcd/etcd-server.crt \\
  peer-key-file=/etc/etcd/etcd-server.key \\
  trusted-ca-file=/etc/etcd/ca.crt \\
  peer-trusted-ca-file=/etc/etcd/ca.crt \\
  peer-client-cert-auth \\
  client-cert-auth \\
  initial-advertise-peer-urls https://${INTERNAL_IP}:2380 \\
  listen-peer-urls https://${INTERNAL_IP}:2380 \\
  listen-client-urls https://${INTERNAL_IP}:2379,https://127.0.0.1:2379 \\
  advertise-client-urls https://${INTERNAL_IP}:2379 \\
  initial-cluster-token etcd-cluster-0 \\
  initial-cluster master-1=https://192.168.25.11:2380,master-2=https://192.168.25.12:2380 \\
  initial-cluster-state new \\
  data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
~~~

~~~
  sudo systemctl daemon-reload
  sudo systemctl enable etcd
  sudo systemctl start etcd
~~~

- master-1/master-2 / test

~~~
ETCDCTL_API=3 etcdctl member list \
endpoints=https://127.0.0.1:2379 \
cacert=/etc/etcd/ca.crt \
 cert=/etc/etcd/etcd-server.crt \
 key=/etc/etcd/etcd-server.key
~~~

08.Kubernetes 컨트롤 플레인 설치
===

- master-1/master-2

~~~
wget  \
  "https://storage.googleapis.com/kubernetes-release/release/v1.15.4/bin/linux/amd64/kube-apiserver" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.15.4/bin/linux/amd64/kube-controller-manager" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.15.4/bin/linux/amd64/kube-scheduler" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.15.4/bin/linux/amd64/kubectl"
~~~
~~~
chmod +x kube-apiserver kube-controller-manager kube-scheduler kubectl
sudo mv kube-apiserver kube-controller-manager kube-scheduler kubectl /usr/local/bin/
sudo mkdir -p /var/lib/kubernetes/
sudo cp ca.crt ca.key kube-apiserver.crt kube-apiserver.key \
service-account.key service-account.crt \
etcd-server.key etcd-server.crt \
encryption-config.yaml /var/lib/kubernetes/
~~~

~~~
INTERNAL_IP=$(ip addr show eth1| grep "inet " | awk '{print $2}' | cut -d / -f 1)
~~~
~~~
cat <<EOF | sudo tee /etc/systemd/system/kube-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-apiserver \\
advertise-address=${INTERNAL_IP} \\
allow-privileged=true \\
apiserver-count=3 \\
audit-log-maxage=30 \\
audit-log-maxbackup=3 \\
audit-log-maxsize=100 \\
audit-log-path=/var/log/audit.log \\
authorization-mode=Node,RBAC \\
bind-address=0.0.0.0 \\
client-ca-file=/var/lib/kubernetes/ca.crt \\
enable-admission-plugins=NodeRestriction,ServiceAccount \\
enable-swagger-ui=true \\
enable-bootstrap-token-auth=true \\
etcd-cafile=/var/lib/kubernetes/ca.crt \\
etcd-certfile=/var/lib/kubernetes/etcd-server.crt \\
etcd-keyfile=/var/lib/kubernetes/etcd-server.key \\
etcd-servers=https://192.168.25.11:2379,https://192.168.25.12:2379 \\
event-ttl=1h \\
encryption-provider-config=/var/lib/kubernetes/encryption-config.yaml \\
kubelet-certificate-authority=/var/lib/kubernetes/ca.crt \\
kubelet-client-certificate=/var/lib/kubernetes/kube-apiserver.crt \\
kubelet-client-key=/var/lib/kubernetes/kube-apiserver.key \\
kubelet-https=true \\
runtime-config=api/all \\
service-account-key-file=/var/lib/kubernetes/service-account.crt \\
service-cluster-ip-range=10.96.0.0/24 \\
service-node-port-range=30000-32767 \\
tls-cert-file=/var/lib/kubernetes/kube-apiserver.crt \\
tls-private-key-file=/var/lib/kubernetes/kube-apiserver.key \\
v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
~~~
~~~
sudo systemctl daemon-reload
sudo systemctl enable kube-apiserver
sudo systemctl start kube-apiserver
~~~

~~~
sudo mv kube-controller-manager.kubeconfig /var/lib/kubernetes/
~~~
~~~
cat <<EOF | sudo tee /etc/systemd/system/kube-controller-manager.service
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-controller-manager \\
  address=0.0.0.0 \\
  cluster-cidr=192.168.25.0/24 \\
  cluster-name=kubernetes \\
  cluster-signing-cert-file=/var/lib/kubernetes/ca.crt \\
  cluster-signing-key-file=/var/lib/kubernetes/ca.key \\
  kubeconfig=/var/lib/kubernetes/kube-controller-manager.kubeconfig \\
  leader-elect=true \\
  root-ca-file=/var/lib/kubernetes/ca.crt \\
  service-account-private-key-file=/var/lib/kubernetes/service-account.key \\
  service-cluster-ip-range=10.96.0.0/24 \\
  use-service-account-credentials=true \\
  v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
~~~

~~~
sudo systemctl daemon-reload
sudo systemctl enable kube-controller-manager
sudo systemctl start kube-controller-manager
~~~

~~~
sudo mv kube-scheduler.kubeconfig /var/lib/kubernetes/
~~~

~~~
cat <<EOF | sudo tee /etc/systemd/system/kube-scheduler.service
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-scheduler \\
  kubeconfig=/var/lib/kubernetes/kube-scheduler.kubeconfig \\
  address=127.0.0.1 \\
  leader-elect=true \\
  v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
~~~
~~~
{
  sudo systemctl daemon-reload
  sudo systemctl enable kube-scheduler
  sudo systemctl start kube-scheduler
}
~~~

- loadbalancer

~~~
vagrant ssh loadbalancer

sudo yum  install -y haproxy
~~~
~~~
cat <<EOF | sudo tee /etc/haproxy/haproxy.cfg
frontend kubernetes
    bind 192.168.25.30:6443
    option tcplog
    mode tcp
    default_backend kubernetes-master-nodes

backend kubernetes-master-nodes
    mode tcp
    balance roundrobin
    option tcp-check
    server master-1 192.168.25.11:6443 check fall 3 rise 2
    server master-2 192.168.25.12:6443 check fall 3 rise 2
EOF
~~~

~~~
sudo service haproxy start
~~~
~~~
curl https://192.168.25.30:6443/version -k
~~~

09.쿠버네티스 worker node 구성
===

- master-1
~~~
cat> openssl-worker-1.cnf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = worker-1
IP.1 = 192.168.25.21
EOF
~~~
~~~
openssl genrsa -out worker-1.key 2048
openssl req -new -key worker-1.key -subj "/CN=system:node:worker-1/O=system:nodes" -out worker-1.csr -config openssl-worker-1.cnf
openssl x509 -req -in worker-1.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out worker-1.crt -extensions v3_req -extfile openssl-worker-1.cnf -days 1000
~~~
~~~
LOADBALANCER_ADDRESS=192.168.25.30
~~~
~~~
kubectl config set-cluster kubernetes-the-hard-way \
    certificate-authority=ca.crt \
    embed-certs=true \
    server=https://${LOADBALANCER_ADDRESS}:6443 \
    kubeconfig=worker-1.kubeconfig

  kubectl config set-credentials system:node:worker-1 \
    client-certificate=worker-1.crt \
    client-key=worker-1.key \
    embed-certs=true \
    kubeconfig=worker-1.kubeconfig

  kubectl config set-context default \
    cluster=kubernetes-the-hard-way \
    user=system:node:worker-1 \
    kubeconfig=worker-1.kubeconfig

  kubectl config use-context default kubeconfig=worker-1.kubeconfig
~~~
~~~
scp ca.crt worker-1.crt worker-1.key worker-1.kubeconfig worker-1:~/
~~~
~~~
vagrant ssh worker-1
~~~

- worker-1
~~~
wget \
  https://storage.googleapis.com/kubernetes-release/release/v1.15.4/bin/linux/amd64/kubectl \
  https://storage.googleapis.com/kubernetes-release/release/v1.15.4/bin/linux/amd64/kube-proxy \
  https://storage.googleapis.com/kubernetes-release/release/v1.15.4/bin/linux/amd64/kubelet
~~~
~~~
sudo mkdir -p /etc/cni/net.d /opt/cni/bin /var/lib/kubelet /var/lib/kube-proxy /var/lib/kubernetes /var/run/kubernetes
chmod +x kubectl kube-proxy kubelet
sudo mv kubectl kube-proxy kubelet /usr/local/bin/
sudo mv ${HOSTNAME}.key ${HOSTNAME}.crt /var/lib/kubelet/
sudo mv ${HOSTNAME}.kubeconfig /var/lib/kubelet/kubeconfig
sudo mv ca.crt /var/lib/kubernetes/
~~~
~~~
cat <<EOF | sudo tee /var/lib/kubelet/kubelet-config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/var/lib/kubernetes/ca.crt"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - "10.96.0.10"
resolvConf: "/run/systemd/resolve/resolv.conf"
runtimeRequestTimeout: "15m"
EOF
~~~
~~~
cat <<EOF | sudo tee /etc/systemd/system/kubelet.service
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=docker.service
Requires=docker.service

[Service]
ExecStart=/usr/local/bin/kubelet \\
  config=/var/lib/kubelet/kubelet-config.yaml \\
  image-pull-progress-deadline=2m \\
  kubeconfig=/var/lib/kubelet/kubeconfig \\
  tls-cert-file=/var/lib/kubelet/${HOSTNAME}.crt \\
  tls-private-key-file=/var/lib/kubelet/${HOSTNAME}.key \\
  network-plugin=cni \\
  register-node=true \\
  v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
~~~

- worker-1 kube-proxy 설치
~~~
sudo mv kube-proxy.kubeconfig /var/lib/kube-proxy/kubeconfig
~~~
~~~
cat <<EOF | sudo tee /var/lib/kube-proxy/kube-proxy-config.yaml
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
clientConnection:
  kubeconfig: "/var/lib/kube-proxy/kubeconfig"
mode: "iptables"
clusterCIDR: "192.168.25.0/24"
EOF
~~~
~~~
cat <<EOF | sudo tee /etc/systemd/system/kube-proxy.service
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-proxy \\
  config=/var/lib/kube-proxy/kube-proxy-config.yaml
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
~~~
~~~
  sudo systemctl daemon-reload
  sudo systemctl enable kubelet kube-proxy
  sudo systemctl start kubelet kube-proxy
~~~

- master-1
~~~
kubectl get nodes kubeconfig admin.kubeconfig
~~~
~~~
cat > openssl-worker-2.cnf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = worker-2
IP.1 = 192.168.25.22
EOF
~~~
~~~
openssl genrsa -out worker-2.key 2048
openssl req -new -key worker-2.key -subj "/CN=system:node:worker-2/O=system:nodes" -out worker-2.csr -config openssl-worker-2.cnf
openssl x509 -req -in worker-2.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out worker-2.crt -extensions v3_req -extfile openssl-worker-2.cnf -days 1000
~~~
~~~
LOADBALANCER_ADDRESS=192.168.25.30
~~~
~~~

  kubectl config set-cluster kubernetes-the-hard-way \
    certificate-authority=ca.crt \
    embed-certs=true \
    server=https://${LOADBALANCER_ADDRESS}:6443 \
    kubeconfig=worker-2.kubeconfig

  kubectl config set-credentials system:node:worker-2 \
    client-certificate=worker-2.crt \
    client-key=worker-2.key \
    embed-certs=true \
    kubeconfig=worker-2.kubeconfig

  kubectl config set-context default \
    cluster=kubernetes-the-hard-way \
    user=system:node:worker-2 \
    kubeconfig=worker-2.kubeconfig

  kubectl config use-context default kubeconfig=worker-2.kubeconfig
~~~
~~~
scp ca.crt worker-2.crt worker-2.key worker-2.kubeconfig worker-2:~/
~~~
~~~
wget \
  https://storage.googleapis.com/kubernetes-release/release/v1.15.4/bin/linux/amd64/kubectl \
  https://storage.googleapis.com/kubernetes-release/release/v1.15.4/bin/linux/amd64/kube-proxy \
  https://storage.googleapis.com/kubernetes-release/release/v1.15.4/bin/linux/amd64/kubelet

sudo mkdir -p /etc/cni/net.d /opt/cni/bin /var/lib/kubelet /var/lib/kube-proxy /var/lib/kubernetes /var/run/kubernetes

chmod +x kubectl kube-proxy kubelet
sudo mv kubectl kube-proxy kubelet /usr/local/bin/
~~~
~~~
sudo mv ${HOSTNAME}.key ${HOSTNAME}.crt /var/lib/kubelet/
sudo mv ${HOSTNAME}.kubeconfig /var/lib/kubelet/kubeconfig
sudo mv ca.crt /var/lib/kubernetes/
~~~
~~~
cat <<EOF | sudo tee /var/lib/kubelet/kubelet-config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/var/lib/kubernetes/ca.crt"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - "10.96.0.10"
resolvConf: "/run/systemd/resolve/resolv.conf"
runtimeRequestTimeout: "15m"
EOF
~~~
~~~
cat <<EOF | sudo tee /etc/systemd/system/kubelet.service
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=docker.service
Requires=docker.service

[Service]
ExecStart=/usr/local/bin/kubelet \\
  config=/var/lib/kubelet/kubelet-config.yaml \\
  image-pull-progress-deadline=2m \\
  kubeconfig=/var/lib/kubelet/kubeconfig \\
  tls-cert-file=/var/lib/kubelet/${HOSTNAME}.crt \\
  tls-private-key-file=/var/lib/kubelet/${HOSTNAME}.key \\
  network-plugin=cni \\
  register-node=true \\
  v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
~~~
~~~
sudo mv kube-proxy.kubeconfig /var/lib/kube-proxy/kubeconfig
~~~
~~~
cat <<EOF | sudo tee /var/lib/kube-proxy/kube-proxy-config.yaml
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
clientConnection:
  kubeconfig: "/var/lib/kube-proxy/kubeconfig"
mode: "iptables"
clusterCIDR: "192.168.25.0/24"
EOF
~~~
~~~
cat <<EOF | sudo tee /etc/systemd/system/kube-proxy.service
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-proxy \\
  config=/var/lib/kube-proxy/kube-proxy-config.yaml
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
~~~
~~~
sudo systemctl daemon-reload
sudo systemctl enable kubelet kube-proxy
sudo systemctl start kubelet kube-proxy
~~~

011.원격 액세스를위한 kubectl 구성
===

-master-1
~~~
 kubectl config set-cluster kubernetes-the-hard-way \
    certificate-authority=ca.crt \
    embed-certs=true \
    server=https://192.168.25.30:6443 \
    kubeconfig=0919.kubeconfig

  kubectl config set-credentials admin \
    client-certificate=admin.crt \
    client-key=admin.key \
    embed-certs=true \
    kubeconfig=0919.kubeconfig

  kubectl config set-context default \
    cluster=kubernetes-the-hard-way \
    user=admin \
    kubeconfig=0919.kubeconfig
~~~
~~~
kubectl get nodes --kubeconfig 0919.kubeconfig
kubectl get componentstatuses  --kubeconfig 0919.kubeconfig
~~~
~~~
 scp 0919.kubeconfig root@192.168.25.1:~/
~~~

- host
~~~
kubectl config use-context default kubeconfig=0919.kubeconfig
cp 0919.kubeconfig ~/.kube/config
~~~

012.네트워크 프로비저닝
===

- worker-1/worker-2

~~~
wget https://github.com/containernetworking/plugins/releases/download/v0.8.2/cni-plugins-linux-amd64-v0.8.2.tgz

sudo tar -xzvf cni-plugins-linux-amd64-v0.8.2.tgz directory /opt/cni/bin/
~~~

- master-1
~~~
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
~~~

013.Kubelet 인증을위한 RBAC
===

- master-1
~~~
cat <<EOF | kubectl apply kubeconfig admin.kubeconfig -f -
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:kube-apiserver-to-kubelet
rules:
  - apiGroups:
      - ""
    resources:
      - nodes/proxy
      - nodes/stats
      - nodes/log
      - nodes/spec
      - nodes/metrics
    verbs:
      - "*"
EOF
~~~
~~~
cat <<EOF | kubectl apply kubeconfig admin.kubeconfig -f -
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: system:kube-apiserver
  namespace: ""
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:kube-apiserver-to-kubelet
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: kube-apiserver
EOF
~~~

014.DNS Cluster Add-on 배포
===

- master-1
~~~
kubectl apply -f https://raw.githubusercontent.com/mmumshad/kubernetes-the-hard-way/master/deployments/coredns.yaml

kubectl get pods -l k8s-app=kube-dns -n kube-system
~~~
~~~
kubectl run generator=run-pod/v1  busybox1 image=busybox:1.28 command  sleep 3600

kubectl get pods -l run=busybox1

kubectl exec -ti busybox1  nslookup kubernetes
~~~
