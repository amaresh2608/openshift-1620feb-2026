# Day 2

## Info - Container Orchestration Platform
<pre>
- Decides where your containerized application workloads are going to run
- Restarts when those containerized application instances crashes
- Scales them up/down automatically based on cpu usage or memory usage or based on other performance metrics
- Handles networking and storage
- Performs rolling updates
  - Upgrading your already live application instances from one version to other without downtime
- Performs load-balancing
- Supports Scheduling
- Supports self-healing
- Supports caling
- Supports Service Discovery
  - Containerized applications finds and talks to each other reliably irrespective of where they are running
- examples
  - Docker SWARM
  - Kubernetes
  - Red Hat Openshift
</pre>

## Info - Docker SWARM
<pre>
- Docker Inc's native Container Orchestration Platform
- it is opensource product
- It only supports application containerized using Docker
- it is very lightweight and user-friendly
- ideal for learning
- easy to setup on laptop or even machines with low-end configurations
- not production grade
- hence used only in Dev/QA environment
</pre>

## Info - Kubernetes
<pre>
- Kubernetes is developed in Golang by Google
- it is opensource
- it is user-friendly and robust
- can be installed in laptops with low-end or every high-end configurations
- even can be installed on Raspberry Pi
- supports imperative(using commands in command-line) and declarative(using yaml files) to deploy and manage applications
- time-tested and production-grade
- can be used in Dev/QA and Production as it is very robust and reliable even for heavy applications
- the smallest unit that can be deployed in Kubernetes is a Pod
- Pod is a collection of many related containers
- Supports many different types of in-built controller to manage Pods
- User applications runs as containers within Pod
- Kubernetes as a cluster of many servers ( Virtual Machines or Physical Machines with any Linux Distro )
- there are 2 types of Nodes(Servers) in Kubernetes
  1. Master Node 
     - Control Plane components runs here
       1. API Server
       2. etcd key/value database (distributed database - works as a cluster )
       3. scheduler
       4. Controller Managers ( collection of many controllers )
  2. Worker Node
- Kuberentes support many different type of Container Runtime/Engines
  - Docker
  - Containerd
  - Podman
  - runC container runtime
  - CRI-O container runtime
- Kubernetes supports CRI ( Container Runtime Interface )
  - any Container Runtime that implements the CRI are supported by Kubernetes
  - Kubernetes interacts with Container Runtimes via the common CRI
- Kubernetes supports only Command-line, doesn't support production-grade webconsole
- Kubernetes provides basic build block to extend it further
  - we can add Custom resource by creating a Custom Resource Definition (CRDs)
  - To manage your Custom resource, you also need to provide Custom Controller
  - this kind of extensions are normally packaged in the form of Kubernetes Operators
- Kubernetes deploying application with container images
- Kubernetes Operators
  - is a collection of many Custom Resources with Custom Controllers
  - one can develop Operators with Operator SDK
    - Ansible Playbook ( equally powerful )
    - Helm Package Manager 
    - Golang ( most preferred ) 
- Kuberentes allows exposing application for
  - internal use via ClusterIP Service
  - external use via NodePort, LoadBalancer Service
</pre>    

## Info - Red Hat Openshift
<pre>
- it is developed on top of Google Kuberenetes
- in other words, Red Hat Openshift is a Red Hat's distribution of Kubernetes with many additional features
- comes with world-wide support from Red Hat ( an IBM company )
- Using the Kubernetes extensions ( Operators ), Openshift team has added many additional useful features
  - Web Console (GUI)
  - User Management
  - DeploymentConfig (deprecated in recent version)
  - Route ( a way to expose your applications to end-users using public url )
    - doesn't cost anyway, as it works like LoadBalancer but uses native openshift implementions
    - internally it uses Kubernetes Ingress
  - S2I ( Source to Image )
    - in addition to deploy application from container images, 
      applications can also be deployed from source code present in GitHub, GitLab, BitBucket, etc.,
    - Build, BuildConfig ( additional resources they added in Openshift )
  - comes with an Internal Image Registry that can be accessed by all nodes in Openshift to push/pull container images
- also supports Serverless declarative CI/CD Framework Tekton
- Tekton is knative (Kubernetes Native project that supports CI/CD in K8s/Openshift )
- Openshift supports all Kuberenetes Service
  - and Route
</pre>

## Info - Creating and Managing Users,Groups in OpenShift
<pre>
- Authentication in OpenShift is managed by authentication operator
- authentication operator runs an oauth-server
- oauth-server is where the users obtain oauth access token to authenticate into the API
- oauth server can be configured to use identify providers such as htpasswd, LDAP, GitLab, etc.,  
</pre>

## Info - Kubernetes High-Level Architecture
![Kubernetes](KubernetesArchitecture2.png)

## Info - Red Hat Openshift High-Level Architecture
![Openshift](openshiftArchitecture.png)
![Openshift](master-node.png)

## Lab - Check your lab for openshift installation
```
kubectl version
oc version

cat ~/openshift.txt
oc login $(oc whoami --show-server) -u kubeadmin -p xkHzc-Pv36w-NcB5W-EwAd3 --insecure-skip-tls-verify=true

oc get nodes
kubectl get nodes
```
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/c2ca1b18-4f99-476d-9404-930c066f153e" />
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/d9f859eb-62db-4645-bf71-2c70617ce0da" />


## Lab - Finding node details
```
oc get nodes

oc describe node master01.ocp4.palmeto.org
oc describe node worker01.ocp4.palmeto.org

```
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/f6c80a0e-51a1-4778-a24e-393d83375349" />
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/d1c65ec6-e0ac-456a-a26b-5ed1452102a3" />
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/92296a2d-86df-4ee0-b625-b79ddc3362fe" />
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/c79088df-aceb-4dc7-a191-2c19a5b0333c" />
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/e00c6bb2-d107-4aeb-a13a-7122a8ed4f75" />
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/d2d42ff7-7b72-44c8-9c3d-61b3de4df15d" />

## Info - Control Plane Components
<pre>
- Control Plane components runs in the master node
- each master nodes has the below Pods
  1. API Server
  2. etcd database server
  3. scheduler
  4. Controller Managers
</pre>

## Info - API Server
<pre>
- this is the brain/heart of Kubernetes/Openshift cluster
- this is a Pod that runs in all master nodes
- API Server supports REST API for all the features supported in Openshift
- all the Control Plane components they only talk to API Server via REST calls
- API Server in returns responds by broadcasting events
- Each API Server updates the etcd database, it will result API Server sending broadcasting events
</pre>

## Info - etcd database server
<pre>
- it is an opensource project
- this is a Pod that runs in all master nodes
- stores data in the form of key/value internally
- it works as a cluster of etcd instances
- to form a minimal etcd cluster it requires at 3 etcd db server instance
- hence, Openshift requires 3 master nodes
- API Server stores the cluster and application state in the etcd database
</pre>

## Info - Scheduler
<pre>
- this is a Pod that runs in all master nodes
- this is responsible to identify a healthy node where new pod can be scheduled
- scheduler by itself won't schedule a pod onto a node, instead the scheduler sends its scheduling
  recommendations via REST call to API Server
</pre>

## Info - Controller Managers
<pre>
- this is a Pod that runs in all master nodes  
- it is a group of many Controllers
- each Controller manages one type of Openshift Resource
- Controllers does the application monitoring
- For example
  - Deployment Controller manages Deployment resource
  - ReplicaSet Controller manages ReplicaSet resource
  - Endpoint Controller manages Endpoints resource
  - Job Controller manages Job resource
  - CronJob Controller manages CronJob resource
  - DaemonSet Controller manages DaemonSet
  - StatefulSet Controller manages StatefulSet
  - Build Controller manages Build 
</pre>

## Info - Pod
<pre>
- is a group of Containers
- each Pod has atleast 2 Containers
  - secret infra-container called pause container
  - application container
- in addition to the above containers, a Pod may also optionally have many other containers
- in general, one Pod should have just one application container
- though technically a Pod may contain many application container, it is not a best practice
- IP Address is assigned on the Pod level
  - meaning all containers that are part of a Pod shares the same IP address and Port range ( 0 - 65536 )
</pre>

## Info - Kubelet
<pre>
- this is not a Pod
- this runs as a Service in every node ( master and worker nodes )
- this interacts with CRI-O Container Runtime to pull, create and manage containers
- this is also called as Kubelet Container Agent
</pre>

## Demo - Getting inside a node 
```
oc debug node/worker01.ocp4.palmeto.org
chroot /host
hostname
hostname -i
ls

podman version
crictl version
crictl images

crictl ps
```

## Lab - Let's create a project to deploy our application
In the command below, replace 'jegan' with your name
```
oc new-project jegan
```
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/73255e9f-5f77-4295-b4cd-bd8ddfd528b9" />

List all projects
```
oc get projects
oc get project
```
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/848f184f-a25c-4ba3-8349-548a335b914b" />

Find more details about a project
```
oc describe project/jegan
```
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/da9cb399-4b7d-4617-9d3d-ee79aa7ce819" />

Switching between projects
```
oc project default
```
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/8b7752c1-c07b-4cef-b5e7-e64a0702eead" />

Finding the currently active project
```
oc project
```

Switch back to your project
```
oc project jegan
```

## Lab - Let's deploy our first stateless application into Openshift within your project
```
oc project jegan

# Find the image present in your openshift cluster
oc get imagestreams -n openshift | grep nginx

# Server 1 (192.168.10.200)
oc create deployment nginx --image=image-registry.openshift-image-registry.svc:5000/openshift/nginx:1.29 --replicas=3

# Server 2 (192.168.10.201)
oc create deployment nginx --image=image-registry.openshift-image-registry.svc:5000/openshift/nginx:1.30 --replicas=3
```

Let's list the deployments in your project
```
oc get deployments
oc get deployment
oc get deploy
```
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/ab8424e8-d057-4001-9f53-c4e7d0b7829b" />


Let's list all the replicasets in your project
```
oc get replicasets
oc get replicaset
oc get rs
```
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/6f78174c-4492-44d0-960d-51305832e5ff" />

Let's list all the pods
```
oc get pods
oc get pod
oc get po
```
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/74a4785b-a08d-49f7-88f4-e5441cec03e5" />

In case your pods are reporting ImagePullBack error, you may edit and replace the image as shown below
```
oc edit deploy/nginx
oc get pods -w
```
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/b5d01552-d3af-444c-8690-fa8f91ac5f09" />
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/48076d33-9687-4997-8766-10beee8ceb43" />

Alternatively, you can update the image as shown below
```
oc set image deploy/nginx nginx=image-registry.openshift-image-registry.svc:5000/openshift/nginx:1.30
```

Scale up the pods
```
oc scale deploy/nginx --replicas=5
oc get pods
```

Scale down the pod count
```
oc scale deploy/nginx --replicas=3
oc get pods
```

<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/956625ee-264e-4f4e-8c39-600afa08e1fe" />

## Lab - Find the application status
```
oc describe deploy/nginx
oc describe rs/nginx-675c65fdcb
oc describe pod/nginx-675c65fdcb-d9k4k
```

