08. Kubernetes 컨트롤 플레인 설치
=====

- master-1/master-2

~~~
wget  \
  "https://storage.googleapis.com/kubernetes-release/release/v1.15.4/bin/linux/amd64/kube-apiserver" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.15.4/bin/linux/amd64/kube-controller-manager" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.15.4/bin/linux/amd64/kube-scheduler" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.15.4/bin/linux/amd64/kubectl"
~~~
