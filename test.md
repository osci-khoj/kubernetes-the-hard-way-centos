005. 구성파일 배포
=============

-master-1
~~~
LOADBALANCER_ADDRESS=192.168.25.30
~~~
- kube-proxy kubeconfig 파일 -
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
