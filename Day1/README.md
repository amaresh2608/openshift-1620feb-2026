# Day 1

## Info - Hypervisor Overview
<pre>
- is nothing but virtualization technology
- with virtualization technology, we can run multiple OS within virtual machines on the same laptop/desktop/workstation/server
- i.e many OS can actively run side by side
- there are 2 types of Hypervisors
  
  1. Type 1 (a.k.a Bare Metal Hypervisor)
  - this type of Hypervisor will be installed on the server directly without any OS
  - Hypervisor itself supports a minimal OS 
  - meant to be used by Workstations & Servers
  - examples
    - KVM
    - Microsoft Hyper-V
    - VMWare vSphere/vCenter
  
  2. Type 2 (a.k.a Hosted Hypervisor)
  - can only be installed on top of some Host OS ( Windows, Linux or Mac OS-X )
  - meant to be used by Laptops/Desktops and Workstations
  - examples
    - Oracle VirtualBox ( Windows, Linux & Mac OS-X )
    - VMWare Workstation ( Windows & Linux )
    - VMWare Fusion ( Mac OS-X )
    - Parallels ( Mac OS-X )

- this type of Virtualization is considered heavy-weight virtualization
- the reason being, for each Virtual Machine, we need to allocate dedicated Hardware resources
  - CPU Cores
  - RAM
  - Storage (HDD/SDD)
</pre>

## Info - Hypervisor High-Level Architecture
![Hypervisor](HypervisorHighLevelArchitecture.png)

## Info - Container Technology
<pre>
- is an application virtualization technology
- each application runs in a separate container
- each container uses about 8 namespaces
- container are nothing but application process that runs in a separate namespace
- all containers that runs on the same machines, share the OS Kernel and Hardware resources on the
  underlying Host OS
- as containers doesn't expect dedicated hardware resources, this type of virtualization is considered
  light weight virtualization
- in Linux Kernel that supports containers
  - namespace and
    - helps us isolate one container from the other
  - CGroups ( Control group )
    - helps us apply resource quota restrictions on the container leve
    - example
      - we can restrict how much CPU a particular container can utilize at the max
      - we can restrict how much RAM a particular container can utilize at the max
</pre>

## Info - Container Runtime
<pre>
- is a low-level software, that helps us manage containers and container images
- container runtimes, depends on the Linux Kernel namespaces, Control Groups to supports containers
- it is not so user-friendly, hence they are not used by end-users like us
- examples
  - runC 
  - cRun
  - CRI-O
</pre>

## Info - Container Engine
<pre>
- is a high-level software, that helps us manage containers and container images
- container engines, depends on Container Runtimes to manage containers and container images
- it is very user-friendly, hence almost all end-users only are aware of Container Engines
- examples
  - Docker 
    - depends on containerd, which in turn depends on runC Container runtime
  - Podman
    - depends on CRI-O container runtime
  - Containerd
    - depends on runC container runtime
</pre>

## Info - Docker Overview
<pre>
- Docker Container Engine is developed in Golang by a company called Docker Inc
- Docker comes in 2 flavours
  1. Docker Community Edition - Docker CE ( opensource )
  2. Docker Enteprise Edition - Docker EE ( commercial product that comes with Support )
- Docker follows Client/Server Architecture
- Client tool is docker
- The Server is dockerd, that runs as a service in the background
</pre>

## Info - Docker High-Level Architecture
![Docker](docker-architecture.jpg)
![Docker](DockerHighLevelArchitecture.png)

## Info - Docker Image
<pre>
- is a JSON file that refers one to many Docker Image Layers
- is a blueprint/specification of containers
- all the necessary software tools that are required to run an application are bundled as part of the Docker Image
- this is similar to Window12OS.iso, RHEL-os.iso
- with a Docker Image, we can create any number of containers
- application + all dependent libraries + any dependencies => bundled => docker image
- each image will have one or more image layers
- image layers can be shared by multiple images
</pre>
![Docker](DockerLayers.png)

## Info - Linux Namespaces
<pre>
- Linux supports a total of 8 types of namespaces
- mnt
  - useful to mount multiple folders as filesystem
- pid
  - a process may have a unique PID system-wide and a different pid within the namespace as 1
- net
  - isolates network stack
  - ip addresses
  - ports
  - routing tables
- ipc
  - message queues
  - mutex, semphares, etc
- uts
  - hostname
  - domain names, etc
- user
  - isolates users and groups
  - rootless containers use this namespace
- cgroup
  - virtualizes /proc/self/cgroup
  - containers only see their cgroup hierarchy
- time
  - useful for checkpoint/restore containers
  - system clock
</pre>

## Info - Docker Container
<pre>
- is a running instance of a Docker image
- in order to create a Docker container, the respective Docker image must be present in the local docker registry
- typically in Linux, local registry folder will be /var/EXPOSE 80lib/docker
- each container represents a single application process
- each container has its own network namespace
- each container has its own pid namespace
- each container has its own mnt namespace
- each container has its own uts, ipc, user and cgroup namespaces
</pre>

## Info - Docker Registry
<pre>
- is a collection of many Docker images
- there are 3 types of Docker Registry
  1. Local Docker Registry
     - /var/lib/docker folder
  2. Private Docker Registry ( optional )
     - can be setup using Sonatype Nexus or JFrog Artifactory
  3. Remote Docker Registry 
     - it is a website maintained by Docker Inc organization that supports the Docker Engine
     - it uses a Server similar to Sonatype Nexus or JFrog Artifactory
</pre>

## Info - Installing Docker CE in Ubuntu
```
# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update

sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo usermod -aG docker $USER
su $USER
docker --version
docker images
```

## Lab - Troubleshooting Docker permission denied error
When it prompts for password, type 'palmeto@123' without quotes. This commands forces a re login of your
currenly logged in user to learn the newly joined user groups.

```
id
su $USER
id
```

## Lab - Finding more details info about your docker installation
```
docker info
```
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/f6573c79-13c9-4963-8fcc-3849759669b9" />


## Lab - Listing the docker images from your local docker registry
```
docker images
```
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/c3e8041c-2264-4df7-a300-77c1d3b2b45b" />

## Lab - Downloading docker image from Docker Hub Remote Registry to Local Docker Registry
```
docker images
docker pull ubuntu:22.04
docker images
```

<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/e49d8eab-a58e-4628-bec3-1f17b51707ac" />


## Lab - Deleting a docker image from local docker registry
```
docker images
docker pull hello-world:latest
docker images

docker rmi hello-world:latest
```
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/2897d7bd-74b3-4c73-abc1-699992d12131" />

## Lab - Creating a container in background(daemon) mode
```

# Creating container and running it in background
docker run -dit --name ubuntu1-jegan --hostname ubuntu1-jegan ubuntu:latest /bin/bash
docker run -dit --name ubuntu2-jegan --hostname ubuntu2-jegan ubuntu:latest /bin/bash
docker run -dit --name ubuntu3-jegan --hostname ubuntu3-jegan ubuntu:latest /bin/bash

# List all currently running containers
docker ps
```

Note
<pre>
run - will create and start the container
dit - deattached interactive terminal
name - is used on the docker level to manage docker containers
hostname - is used on the OS level as an alternate to IP addresses
ubuntu:latest - docker image with which we would like to create a container 
/bin/bash - we would like run a bash terminal as the default application once the container starts running
</pre>

<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/97b0b6fc-e805-4f7f-8719-3f2805055451" />


## Lab - Stopping container

Stopping a single container
```
docker stop ubuntu1-jegan
```

Stopping multiple containers
```
docker stop ubuntu2-jegan ubuntu3-jegan
```

Stopping multiple containers without calling out their names
```
docker stop $(docker ps -q -f --name="ubuntu.*-jegan")
```

Stopping every containers
```
docker stop $(docker ps -q)
```

## Lab - Starting container
Starting a single exited container
```
docker start ubuntu1-jegan
```

Starting multiple exited containers
```
docker start ubuntu2-jegan ubuntu3-jegan
```

Starting multiple containers without their names
```
docker start $(docker ps -aq)
```

<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/76b9b445-6c45-4a4b-af81-5da07cc4f2e4" />
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/5a577fc3-892b-452c-94a5-a261579ab36d" />

## Lab - Restarting container

Restart a container to force apply any config changes 
```
docker restart ubuntu1-jegan
```

Restart multiple containers
```
docker restart ubuntu1-jegan ubuntu2-jegan ubuntu3-jegan
```

Restart all containers
```
docker restart $(docker ps -q)
```

## Lab - Deleting containers

Delete a single running container gracefuly
```
docker stop ubuntu1-jegan
docker rm ubuntu1-jegan
docker ps
```

Delete multiple containers
```
docker stop ubuntu1-jegan ubuntu2-jegan ubuntu3-jegan && docker rm ubuntu1-jegan ubuntu2-jegan ubuntu3-jegan
```

Delete multiple containers forcibly ( You will end up deleting containers created by others too so think twice )
```
docker rm -f $(docker ps -aq)
```

## Lab - Create a container and start it later on-demand
```
docker create -it --name ubuntu1-jegan --hostname ubuntu1-jegan ubuntu:latest /bin/bash

# The below command won't show the ubuntu1-jegan container as it is not running
docker ps | grep jegan

#Start the container manually
docker start ubuntu1-jegan

#List and see the container in running state now
docker ps | grep jegan
```
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/c617008b-c6c8-4777-af92-1a03169c7e64" />

## Lab - Finding container details
```
docker inspect ubuntu1-jegan
```

<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/8db76f16-2ea2-468b-a58b-3ce735765cb4" />
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/70a390a7-90e3-4bc1-8295-d45f09cdcc2a" />


## Lab - Retrieving IP address of a docker container
```
docker inspect ubuntu1-jegan | grep IPA

docker inspect -f {{.NetworkSettings.Networks.bridge.IPAddress}} ubuntu1-jegan
```
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/bdc6e614-26d4-4b7a-8501-028640fc3e5b" />

## Lab - Getting inside a container shell
```
docker ps | grep ubuntu1-jegan
docker exec -it ubuntu1-jegan /bin/bash

hostname
hostname -i

ifconfig

apt update && apt install -y net-tools iputils-ping

ifconfig
ping 8.8.8.8

exit
```
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/72c2a9db-4dbc-43fd-98eb-5221119d8674" />
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/c7cf2a9d-a96d-4bfd-ad7a-4cc1765ebb01" />
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/8dc0e46e-c37f-4f0e-abf8-e28db9dcdb22" />
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/9f73be8c-d388-4edf-9c89-aae5d810aa4f" />

## Lab - Creating a container in the foreground(interactive) mode
```
docker run -it --name ubuntu2-jegan --hostname ubuntu2-jegan ubuntu:latest /bin/bash
hostname
hostname -i
ls
exit
docker ps
```

<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/366a8bf6-f66c-44c7-b386-5e3584945035" />

## Lab - Setting up a Load Balancer with nginx

We are going to create a load-balancer setup something like below
<img width="75%" height="75%" alt="image" src="https://github.com/user-attachments/assets/7122c6b7-5820-407e-bdf6-5bac55c5b40d" />
