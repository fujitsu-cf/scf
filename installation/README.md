# Installation
## Install Docker
The first step is to install Docker.
### Uninstall old versions
```
$ sudo apt-get remove docker docker-engine docker.io
```
### Install using the repository


Update the apt package index:
```
$ sudo apt-get update
```
Install packages to allow apt to use a repository over HTTPS:
```
$ sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
```
Add Docker’s official GPG key:
```
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```
Verify that you now have the key with the fingerprint 9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88, by searching for the last 8 characters of the fingerprint.
```
$ sudo apt-key fingerprint 0EBFCD88

pub   4096R/0EBFCD88 2017-02-22
      Key fingerprint = 9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88
uid                  Docker Release (CE deb) <docker@docker.com>
sub   4096R/F273FCD8 2017-02-22
```

Add repository
```
$ sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
```

Install Docker
```
$ sudo apt-get update
```

```
$ sudo apt-get install docker-ce
```

### Manage Docker as a non-root user
To create the docker group and add your user:

Create the docker group.
```
$ sudo groupadd docker
```
Add your user to the docker group.
```
$ sudo usermod -aG docker $USER
```

And reboot your machine.
After reboot verify your docker:

```
$ docker run hello-world
```

### Add swap memory limit

Open the following file:
```
$ sudo vim /etc/default/grub
```
and update `GRUB_CMDLINE_LINUX` variable:

```
GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"
```
then

```
$ sudo grub-update
$ sudo reboot
```

## Install Kubernetes

### Prerequisite
To avoid problems with kubernetes DNS service please add `ExecStartPre` to Docker service file:
```
$ sudo vim /lib/systemd/system/docker.service
```
and add it before `ExecStart`
```
ExecStartPre=/sbin/iptables -P FORWARD ACCEPT
ExecStart=/usr/bin/dockerd -H fd://

```
then
```
$ sudo systemctl daemon-reload
$ sudo systemctl restart docker
```

#### Set iptables rules
Set `/proc/sys/net/bridge/bridge-nf-call-iptables` to 1 by running `sudo sysctl net.bridge.bridge-nf-call-iptables=1` to pass bridged IPv4 traffic to iptables’ chains.


### Installing kubeadm, kubelet and kubectl

You will install these packages on all of your machines:

 * `kubeadm`: the command to bootstrap the cluster.

 * `kubelet`: the component that runs on all of the machines in your cluster and does things like starting pods and containers.

 * `kubectl`: the command line util to talk to your cluste

```
sudo su
apt-get update && apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl

```

### Initializing your master

The master is the machine where the “control plane” components run, including etcd (the cluster database) and the API server (which the kubectl CLI communicates with).

To initialize the master, pick one of the machines you previously installed kubeadm on, and run:

```
# kubeadm init --apiserver-advertise-address=<ip-address> --pod-network-cidr=10.244.0.0/16
# exit
```

When installation is finished:

```
  $ mkdir -p $HOME/.kube
  $ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  $ sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
### Master Isolation

By default, your cluster will not schedule pods on the master for security reasons. If you want to be able to schedule pods on the master, e.g. a single-machine Kubernetes cluster for development, run:

```
$ kubectl taint nodes --all node-role.kubernetes.io/master-
```

### Installing a pod network

You must install a pod network add-on so that your pods can communicate with each other.
```
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml
```
Restart kubelet service and docker

```
$ sudo systemctl restart kubelet
$ sudo systemctl restart docker
```
Get info about your cluster

```
$ kubectl get nodes
NAME       STATUS    AGE       VERSION
minikube   Ready     9m        v1.8.1
```
or

```
$ kubectl describe nodes
```

### How do I test if it is working?

Create a simple Pod to use as a test environment
```
kubectl create -f https://raw.githubusercontent.com/zreigz/kubernetes-workshop/master/installation-kubeadm/busybox.yaml
```

Wait for this pod to go into the running state
You can get its status with:
```
kubectl get pods busybox
```
You should see:
```
NAME      READY     STATUS    RESTARTS   AGE
busybox   1/1       Running   0          <some-time>
```
Validate that DNS is working
Once that pod is running, you can exec nslookup in that environment:
```
kubectl exec -ti busybox -- nslookup kubernetes.default.svc.cluster.local
```
You should see something like:
```
Server:    10.0.0.10
Address 1: 10.0.0.10

Name:      kubernetes.default
Address 1: 10.0.0.1
```

If you see that, DNS is working correctly.

## Deploying SCF
### Prerequisite
Make sure you have installed `make`

```
$ sudo apt-get install build-essential
```
### Get repository

Clone the repository:

```
$ git clone https://github.com/fujitsu-cf/scf.git
$ cd scf
$ git checkout -b bare-metal origin/bare-metal
$ git submodule sync --recursive
$ git submodule update --init  --recursive

```

Check the IP address of your machine. Setup IP address for host machine in following files (replace the IP address 10.0.0.4 for yours):


 * container-host-files/etc/hcf/config/scripts/manage-hosts.sh

 * kube-external/api-external.yaml

 * make/kube

 * src/uaa-fissile-release/ kube-test/exposed-ports.yml

### Install stampy

```
$ wget https://github.com/SUSE/stampy/releases/download/0.0.0/stampy-0.0.0.22.gbb93bf3.linux-amd64.tgz
$ tar -xzvf stampy-0.0.0.22.gbb93bf3.linux-amd64.tgz
$ sudo cp stampy /usr/local/bin
```
### Install fissile

```
$ wget https://cf-opensusefs2.s3.amazonaws.com/fissile/fissile-5.1.0%2B24.gf03f435.linux-amd64.tgz
$ tar -xzvf fissile-5.1.0+24.gf03f435.linux-amd64.tgz
$ sudo cp fissile /usr/local/bin
```
 
### Prepare the images:
```
$ source .envrc

$ make vagrant-prep

$ make kube

``` 

Check if images are available:
```
$ docker images
```

### Start CF on k8s

Make sure the DNS is working: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/



Create Persistent Volumes for deployment 
```
$ kubectl create -f kube-external/pv.yaml
```
 

Create namespaces
```
$ kubectl create namespace uaa

$ kubectl create namespace cf
```
 

Deploy uaa components

 
```
$ kubectl create -f ./src/uaa-fissile-release/kube/secrets/secret-1.yml -n uaa

$ kubectl create -f ./src/uaa-fissile-release/kube/bosh/mysql.yml -n uaa
```
 

Wait until mysql is running and ready (READY 1/1):

 
```
$ kubectl get pods -n uaa

 

NAME                   READY     STATUS    RESTARTS   AGE

mysql-0                1/1       Running   0          1d

 ```

Then start uaa component:

 
```
$ kubectl create -f ./src/uaa-fissile-release/kube/bosh/uaa.yml -n uaa

$ kubectl create -f ./src/uaa-fissile-release/kube-test/exposed-ports.yml -n uaa

```

 

Wait until uaa is running and ready (READY 1/1):

 
```
$ kubectl get pods -n uaa

NAME                                    READY     STATUS    RESTARTS   AGE

mysql-0                                  1/1          Running     0                   1d

uaa-2401297320-hbfdf     1/1          Running     0                   1d
```

Install rest of CF components:

 
```
$ kubectl create --namespace="cf" --filename="kube/secrets"

$ kubectl create --namespace="cf" --filename="kube/bosh-task/post-deployment-setup.yml"

$ kubectl create --namespace="cf" --filename="kube/bosh"

$ kubectl create -f kube-external/api-external.yaml -n cf
```
 

Now just wait if they are ready:
```
$ kubectl get pods -n cf
```

