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
