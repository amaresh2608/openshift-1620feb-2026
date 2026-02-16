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

## Info - Container Technology
<pre>
- is an application virtualization technology
- each application runs in a separate container
- each container uses 5/8 namespaces
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
</pre>

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
- typically in Linux, local registry folder will be /var/lib/docker
- each container represents a single application process
- each container has its own network namespace
- each container has its own pid namespace
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
