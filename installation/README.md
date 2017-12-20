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


