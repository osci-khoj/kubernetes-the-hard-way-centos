**01.base env**

`git clone https://github.com/osci-khoj/kubernetes-the-hard-way-centos.git
cd kubernetes-the-hard-way-centos/vagrant
vagrant up`

10분 정도 기다림 (화면 주목)

02.vagrant 내 접근허용(반드시 kubernetes-the-hard-way-centos/vagrant 그 위치에서 수행)
 `   vagrant status`
 
master-1

` vagrant ssh master-1`

`ssh-keygen` password: vagrant

`    ssh-copy-id master-2`
