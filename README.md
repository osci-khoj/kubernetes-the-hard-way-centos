
이 문서는 매우 유명한 문서로 실제 kubernetes.io에 GkCP 기반으로 구현되어 있는 Kelsey Hightower 가 작성한 문서를  기반으로 하였습니다. 

이 문서는 Mumshad Mammambeth라는 사람이 virtualbox 기반으로 구현하였습니다. 

저는 이 문서를 최신으로 버전업 하면서, 내부 VM을 모두 centos로 변경하는 작업을 하였습니다. 이유는 이전에 저희팀에서 오픈스택 패키징을 할때도 centos기반으로 해서 유용하였던 적이 여러번 있었기 때문입니다. 

원본 : https://github.com/kelseyhightower/kubernetes-the-hard-way  

       환경 : ubuntu based on GCP

Kubernetes 1.12.0
containerd Container Runtime 1.2.0-rc.0
gVisor 50c283b9f56bb7200938d9e207355f05f79f0d17
CNI Container Networking 0.6.0
etcd v3.3.9
CoreDNS v1.2.2

수정본 : https://github.com/mmumshad/kubernetes-the-hard-way

환경 : ubuntu based on VirtualBox 

Kubernetes 1.13.0
Docker Container Runtime 18.06
CNI Container Networking 0.7.5
Weave Networking
etcd v3.3.9
CoreDNS v1.2.2

우리 환경 : 

환경 : centos based on VirtualBox

kubectl 1.15.3
Kubernetes 1.15.3
Docker Container Runtime 19.03.2
CNI Container Networking 0.8.2
Weave Networking
etcd v3.4
CoreDNS v1.2.2

* [Kubernetes](https://github.com/kubernetes/kubernetes) 1.15.3
* [Docker Container Runtime](https://github.com/containerd/containerd) 18.06
* [CNI Container Networking](https://github.com/containernetworking/cni) 0.7.5
* [Weave Networking](https://www.weave.works/docs/net/latest/kubernetes/kube-addon/)
* [etcd](https://github.com/coreos/etcd) v3.3.9
* [CoreDNS](https://github.com/coredns/coredns) v1.2.2

syntax: [Document](27.255.70.23)
