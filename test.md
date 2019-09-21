- master-1

` vagrant ssh master-1`

`ssh-keygen` password: vagrant

`ssh-copy-id master-2`

`ssh-copy-id worker-1`

`ssh-copy-id worker-2`
`ssh-copy-id lb`

`wget https://storage.googleapis.com/kubernetes-release/release/v1.15.4/bin/linux/amd64/kubectl`
`chmod +x kubectl`
`sudo mv kubectl /usr/local/bin/`
