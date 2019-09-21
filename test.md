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

02. vagrant 내 접근허용
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

`chmod +x kubectl`

`sudo mv kubectl /usr/local/bin/`
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
