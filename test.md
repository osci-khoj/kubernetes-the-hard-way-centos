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

wget https://storage.googleapis.com/kubernetes-release/release/v1.15.4/bin/linux/amd64/kubectl`

chmod +x kubectl

sudo mv kubectl /usr/local/bin/
~~~

`ssh-keygen password: vagrant

ssh-copy-id master-2

ssh-copy-id worker-1

ssh-copy-id worker-2

ssh-copy-id lb

wget https://storage.googleapis.com/kubernetes-release/release/v1.15.4/bin/linux/amd64/kubectl`

chmod +x kubectl
`



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
