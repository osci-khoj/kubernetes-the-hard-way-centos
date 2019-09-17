
kubernetes는 어렵지 않아요. 더군다나 인스톨이 쉬워요.


배를 몰아보아요.
여기서 우리는 몇가지만 기억하면 됩니다. 

우리는 현재 항구에서 배로 무역을 하는 인프라를 관리합니다. 

worker node는 무역선이고, master node는 항구입니다. 

worker node에 있는 kubelet은 선장역할을 하고, 항구와는 kube-apiserver이라는 관제탑과 연락을 주고받습니다. 

항구에는 배의 상태를 지속적으로 체크하며, 과거 배의 상태나 수리내역을 Kube-controller-manager를 통해서 관리합니다. 

또한 항구는 배의 상태를 확인한후, 폭풍우에 맞아 가라앉은 배를 다른배로 교체하고, 물건을 옮기고 하는 일들을 관장하는 kube-scheduler가 있습니다. 

그럼 이러한 모든 배의 정보와 무역에 관한 정보를 가지고 있는곳이 있어야겠지요? 그것은 ETCD라는 곳입니다. 

앞으로 할일 

먼저 무역을 하는 인프라를 구성해 볼거에요. 

이 문서는 매우 유명한 문서로 실제 kubernetes.io에 GCP 기반으로 구현되어 있는 Kelsey Hightower 가 작성한 문서를  기반으로 하였습니다. 

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
