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
