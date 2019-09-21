
`ssh-copy-id lb`

`wget https://storage.googleapis.com/kubernetes-release/release/v1.15.4/bin/linux/amd64/kubectl`

`chmod +x kubectl`

`sudo mv kubectl /usr/local/bin/`


03.CA 프로비저닝 및 TLS 인증서 생성=

CA 인증서-
~~~~
openssl genrsa -out ca.key 2048
openssl req -new -key ca.key -subj "/CN=KUBERNETES-CA" -out ca.csr
openssl x509 -req -in ca.csr -signkey ca.key -CAcreateserial  -out ca.crt -days 1000
~~~~
