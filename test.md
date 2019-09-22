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
`vagrant ssh worker-1`

- worker-1
