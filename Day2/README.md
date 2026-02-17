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

## Demo - Installing htpassword utility in Ubuntu
```
sudo apt install -y apache2-utils
```

## Lab - Creating and Managing Users,Groups in OpenShift 
```
htpasswd -cBb /tmp/htpasswd jegan-admin admin@123
cat /tmp/htpasswd

htpasswd -Bb /tmp/htpasswd jegan-dev dev@123
cat /tmp/htpasswd

oc login $(oc whoami --show-server) -u kubeadmin -p xkHzc-Pv36w-NcB5W-EwAd3 --insecure-skip-tls-verify=true

oc create secret generic htpasswd-secret --from-file htpasswd=/tmp/htpasswd -n openshift-config
oc get oauth cluster -o yaml > oauth.yml
```

Edit the oauth.yml
<pre>
- htpasswd:
    fileData:
      name: htpasswd-secret
  mappingMethod: claim
  name: palmeto-users
  type: HTPasswd
</pre>

Given access permissions to the users created
```
oc replace -f oauth.yml
oc get pods -n openshift-authentication
oc login -u jegan-admin -p admin@123
oc get pods
oc get svc
oc get nodes
oc whoami
oc login $(oc whoami --show-server) -u kubeadmin -p xkHzc-Pv36w-NcB5W-EwAd3 --insecure-skip-tls-verify=true
oc adm policy add-cluster-role-to-user cluster-admin jegan-admin
oc login -u jegan-admin -p admin@123
oc get pods
oc get svc
oc get nodes
oc get users
oc get identify
oc login $(oc whoami --show-server) -u jegan-developer -p dev@123 --insecure-skip-tls-verify=true
oc login $(oc whoami --show-server) -u jegan-admin -p admin@123 --insecure-skip-tls-verify=true

oc get users
oc extract secret/htpassword-secret -n openshift-config --to /tmp --confirm
cat /tmp/htpasswd

# Change password
oc login $(oc whoami --show-server) -u kubeadmin -p xkHzc-Pv36w-NcB5W-EwAd3 --insecure-skip-tls-verify=true
oc extract secret/htpasswd-secret -n openshift-config --to /tmp --confirm
htpasswd -b /tmp/htpasswd jegan-developer developer@123
cat /tmp/htpasswd
oc set data secret/htpasswd-secret --from-file htpasswd=/tmp/htpasswd -n openshift-config
oc get pods -n openshift-authentication
oc login -u jegan-developer developer@123

# Delete User
oc login -u jegan-admin -p admin@123
oc extract secret/htpasswd-secret -n openshift-config --to /tmp --confirm
htpasswd -D /tmp/htpasswd jegan-developer
cat /tmp/htpasswd
oc set data secret/htpasswd-secret --from-file htpasswd=/tmp/htpasswd -n openshift-config
oc delete identify palmeto-users:jegan-developer
oc get identify
oc delete user jegan-developer
oc get users
oc login -u jegan-developer -p developer@123
```
