
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

* [Kubernetes](https://github.com/kubernetes/kubernetes) 1.13.0
* [Docker Container Runtime](https://github.com/containerd/containerd) 18.06
* [CNI Container Networking](https://github.com/containernetworking/cni) 0.7.5
* [Weave Networking](https://www.weave.works/docs/net/latest/kubernetes/kube-addon/)
* [etcd](https://github.com/coreos/etcd) v3.3.9
* [CoreDNS](https://github.com/coredns/coredns) v1.2.2

## Labs

* [Prerequisites](docs/01-prerequisites.md)
* [Provisioning Compute Resources](docs/02-compute-resources.md)
* [Installing the Client Tools](docs/03-client-tools.md)
* [Provisioning the CA and Generating TLS Certificates](docs/04-certificate-authority.md)
* [Generating Kubernetes Configuration Files for Authentication](docs/05-kubernetes-configuration-files.md)
* [Generating the Data Encryption Config and Key](docs/06-data-encryption-keys.md)
* [Bootstrapping the etcd Cluster](docs/07-bootstrapping-etcd.md)
* [Bootstrapping the Kubernetes Control Plane](docs/08-bootstrapping-kubernetes-controllers.md)
* [Bootstrapping the Kubernetes Worker Nodes](docs/09-bootstrapping-kubernetes-workers.md)
* [TLS Bootstrapping the Kubernetes Worker Nodes](docs/10-tls-bootstrapping-kubernetes-workers.md)
* [Configuring kubectl for Remote Access](docs/11-configuring-kubectl.md)
* [Deploy Weave - Pod Networking Solution](docs/12-configure-pod-networking.md)
* [Kube API Server to Kubelet Configuration](docs/13-kube-apiserver-to-kubelet.md)
* [Deploying the DNS Cluster Add-on](docs/14-dns-addon.md)
* [Smoke Test](docs/15-smoke-test.md)
* [E2E Test](docs/16-e2e-tests.md)
* [Extra - Dynamic Kubelet Configuration](docs/17-extra-dynamic-kubelet-configuration.md)
