# Day 4

## Lab - Deploying an application into Openshift using source strategy
```
oc delete project jegan
oc new-project jegan

oc new-app --name=hello registry.access.redhat.com/ubi8/openjdk-17~https://github.com/tektutor/spring-ms.git --strategy=source
# Create a public route for the service hello - this helps us access the application from outside the cluster
oc expose svc/hello

# Checking the build config strategy
oc get bc/hello -o yaml
oc get bc/hello -o yaml | grep Strategy
oc logs -f bc/hello

oc get deploy,pods,svc,route
curl http://hello-jegan.apps.ocp4.palmeto.org
```
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/d380edfd-8248-4e13-ad0a-3500da73748a" />
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/c8f0c186-52f0-4d9f-9008-1f1918bcb2e1" />
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/f18b5cd7-3051-4e94-9294-5ece895f0822" />
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/60913709-8461-4b40-ad63-8787c90baad5" />
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/ef19ce3a-9834-48ea-bf06-a7715bd4e4b0" />

## Lab - Creating an external nodeport service
```
oc project jegan
oc delete svc/hello

# Create an external nodeport service for hello deployment
oc expose deploy/hello --port=8080 --type=NodePort
oc get svc

## Accessing the node port service externally
oc get nodes -o wide
curl http://192.168.100.12:32478
curl http://192.168.100.13:32478
curl http://192.168.100.14:32478

curl http://192.168.100.21:32478
curl http://192.168.100.22:32478
curl http://192.168.100.23:32478
```
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/8bcdd013-324d-4ecb-8b14-2b910d634c24" />
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/13e8a1a9-3a17-4376-8810-510370c9bc23" />


## Info - What happens internally in Openshift when we deploy an application
```
oc create deploy nginx --image=docker.io/bitnamilegay/nginx:latest --replicas=3
```

Note
<pre>
- oc client tool makes a REST call to API Server requesting the API Server to create a deployment
- Once API Server receives the request from oc client, it creates a Deployment database entry in etcd database
- API Server then sends broadcasting event saying new Deployment created along with deployment details
- Deployment Controller receives this event, it then makes a REST call to API Server requesting it to create a ReplicaSet for the nginx deployment
- API Server creates a ReplicaSet db entry(new record) in the etcd database
- API Server sends a broadcast event saying new ReplicaSet created
- ReplicaSet Controller receives the event, it then makes a REST call to API Server requesting it to create 3 Pods
- API Server create 3 Pod records in the etcd database
- API Server sends broadcast event for each new Pod created in the etcd database
- Scheduler receives the event, it then identifies a healthy node where the new Pod can be deployed
- Scheduler makes a REST call to API Server to send it scheduling recommendataion. This will be done for each Pod.
- API Server receives the scheduling recommendations from Scheduler, it then retrieves the Pod record from etcd and updates it status as Scheduled to so and so node
- API Server sends a broadcasting event saying Pod1 scheduled to Worker01 node, this happens for each Pod.
- Kubelet Container Agent that runs on Worker01 node receives the event, it then pull the container image, creates and starts the container on Worker01
- Kubelet monitors the status of the Container created for Pod1, and it periodically updates the status back to API Server in a heart-beat fashion
- API Server receives these updates, retrieves the Pod database entry from etcd and updates the Pod status
</pre>
![Openshift](openshift-internals.png)

## Info - DaemonSet
<pre>
- DaemonSet is managed by DaemonSet Controller
- DaemonSet Controller detects the total number of nodes available in the cluster and it will create that many Pods automatically
- each Pod will scheduled on one of the nodes 
- this is not used in normal scenarios
- For instance, 
  - to collect performance metrics, there has to be one Prometheus Pod running in each node
  - in this kind of scenario, one can use DaemonSet
</pre>

<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/c9d18180-d5c8-4324-91e3-006a1380e7cb" />

## Info - Job
<pre>
- any one time activity, we can run as Job
- the activity may run sometime and then it might complete, such application can be deployed as a Job in Kubernetes/Openshift
</pre>

## Info - CronJob
<pre>
- any activity that must be schedule to run a particular day particular time
- this must be repeated daily, weekly or monthly or yearly then it can be deployed as a CronJob
</pre>

## Info - StatefulSet
<pre>
- this is used to deploy stateful applications
- if you wish to deploy a cluster of db server Pod
- assume you wish to create 3 mysql Pods which runs as a cluster
  - ie. when a particular table record is updated in one instance of mysql Pod
  - it automatically syncs with other 2 instances
- StatefulSet Controller guarantees 
  - each Pod that is created for StatefulSet is guaranteed to have a stable name
  - For instance, assuming the statefulset name is mysql then the first Pod will be named mysql-0, 
    the second Pod will be named mysql-1 and so on
  - Even if the mysql-0 Pod or any Pod in Statefulset get deleted the new mysql Pod is assigned the same sticky name
- First mysql-0 Pod behaves like a Master mysql server
  - here read/write is allowed
- Second and Third instance i.e mysql-1 and mysl-2 can be created as a ready-only database
- Second instance will get synchronized pulling updates from mysql-1 and then it will let the mysql-2 get synchronized from mysql-1
</pre>

## Lab - Horizontal Pod Auto-scaling based on CPU utilization
```
oc delete project jegan
oc new-project jegan

cd ~
git clone https://github.com/tektutor/openshift-1620feb-2026.git
cd openshift-1620feb-2026
cd Day4/auto-scaling
oc create -f hello-deploy.yml --save-config
oc get pods
oc create -f hello-hpa.yml --save-config

oc expose deploy/nginx --port=8080
oc expose svc/nginx
oc get route
```

We need to stress the pod with more traffic
```
ab -k -n 200000 -c 500 https://nginx-jegan.apps.ocp4.palmeto.org/
```
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/5c2b7e73-8470-4526-9f72-84b3f522e225" />
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/04583c99-cbed-4207-ae4e-6dc0948c9cab" />

## Lab - Rolling update

Let's deploy nginx with nginx 1.28 version
```
oc delete project jegan
oc new-project jegan
# Server 1
oc create deployment nginx --image=image-registry.openshift-image-registry.svc:5000/openshift/nginx:1.28 --replicas=3 --dry-run=client -o yaml

# Server 2
oc create deployment nginx --image=image-registry.openshift-image-registry.svc:5000/openshift/nginx:1.30 --replicas=3 --dry-run=client -o yaml

# Server 1
oc create deployment nginx --image=image-registry.openshift-image-registry.svc:5000/openshift/nginx:1.28 --replicas=3 --dry-run=client -o yaml > nginx-deploy.yml

# Server 2
oc create deployment nginx --image=image-registry.openshift-image-registry.svc:5000/openshift/nginx:1.30 --replicas=3 --dry-run=client -o yaml > nginx-deploy.yml
```

You can then update the nginx-deploy.yml as shown below
<pre>
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: image-registry.openshift-image-registry.svc:5000/openshift/nginx:1.29
        name: nginx  
</pre>

Let's create the nginx deployment in the declarative style using manifest(yaml) file
```
oc create -f nginx-deploy.yml --save-config
oc get deploy --show-labels
oc get rs --show-labels
oc get pods --show-labels
```
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/7644e1aa-7070-48f1-a6ed-a3ee031bab28" />

Now let's update the image tag from 1.28 to 1.29 in the nginx-deploy.yml file as shown below
```
sed -i 's/nginx:1.28/nginx:1.29/'  nginx-deploy.yml
cat nginx-deploy.yml
```
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/67b6a0cf-8ec2-4cbc-84f1-74328b01a92f" />

Now let's perform the rolling update ( i.e upgrade nginx from v1.28 to v1.29 )
```
oc apply -f nginx-deploy.yml
oc rollout status deploy/nginx
oc rollout history deploy/nginx

oc get rs --show-labels
oc get pods --show-labels
oc get pods -o yaml | grep image
```

<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/757ac9fc-9f89-4645-ab72-ff7b64461d1b" />

In case the newly deploy application version is found to be unstabe, you can rollback
```
oc rollout undo deploy/nginx
```

Rollback to any specific version
```
oc rollout history deploy/nginx
oc rollout undo deploy/nginx --to-revision=2
```
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/79d5b96f-44ba-4ac0-8fb7-a17e14b3ba35" />

## Lab - Creating an user group, add users to group, restrict access to project

Let's login as administrator
```
oc login $(oc whoami --show-server) -u jegan-admin -p admin@123 --insecure-skip-tls-verify=true
```

Create a group calledRolling update
-Upgrade deployed application from one version to another
-Rollback deployed application from current to older versions
-Checking rolling update status
```
oc adm groups new dev-team
oc get groups
oc describe group dev-team
```

Add users to the group
```
oc adm groups add-users dev-team jegan-dev you-can-add-your-dev-user
```

Create a project
```
oc new-project dev-team-project
oc get projects | grep dev-team
```

Remove default access to project
```
oc adm policy remove-role-from-group view system:authenticated -n dev-team-project
```

Give edit access to dev-team
```
oc adm policy add-role-to-group edit dev-team -n dev-team-project
```

Give view only access to dev-team
```
oc get rolebindings -n dev-team-project
oc adm policy add-role-to-group view dev-team -n dev-team-project
oc get rolebindings -n dev-team-project
```

Give full admin permission to dev-team
```
oc adm policy add-role-to-group admin dev-team -n dev-team-project
```

Login as jegan-dev user
```
oc login $(oc whoami --show-server) -u jegan-dev -p dev@123 --insecure-skip-tls-verify=true
oc get projects
oc project dev-team-project
oc new-app --name=hello https://github.com/tektutor/spring-ms.git --strategy=source
oc get deploy,rs,pods
oc expose deploy/hello --port=8080
oc expose svc/hello
oc get route
curl http://your-route-url
```
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/a06d5a0a-e3ba-4e86-aa0f-e5a7ea4d9714" />
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/551e3fef-67d7-4594-aeb6-54a067eb9016" />
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/84f4a6ce-31ec-4b6f-906a-2273e3ba62ca" />

## Info - ImageStream
<pre>
- Openshift ImageStream represents a folder inside Openshift's Internal Registry 
- We can store multiple versions(tag) of the same image in a single OpenShift Imagestream
</pre>

## Lab - Login to Openshift's Internal image registry

Let's see if there is public route for our Openshift Internal registry
```
oc get route -n openshift-image-registry
```

If you don't see a route there already, we need to create it
```
oc patch configs.imageregistry.operator.openshift.io/cluster \
--type=merge \
-p '{"spec":{"defaultRoute":true}}'
```

The above command will automatically create the route for the Openshift Internal Image registry
```
oc get route -n openshift-image-registry
```

We need to configure docker to support login to insecure registry
```
vim /etc/docker/daemon.json
```
<pre>
{
  "insecure-registries": ["default-route-openshift-image-registry.apps.ocp4.palmeto.org"]
}
</pre>

Now, let's restart docker to apply the config changes done
```
sudo systemctl restart docker
sudo systemctl status docker
```

We can now login to our Openshift Internal registry, assuming you have already logged in as admin user in the terminal
```
docker login -u $(oc whoami) -p $(oc whoami -t) default-route-openshift-image-registry.apps.ocp4.palmeto.org
```
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/d2c02eb9-90d6-4083-a7fe-7a2d0a6f5f30" />

## Lab - Importing image from Docker Hub into Openshift Internal Registry
```
oc project jegan
oc get imagestreams
oc get imagestream
oc get is

oc import-image nginx:1.26 \
--from=docker.io/bitnamilegacy/nginx:1.29 \
--confirm
```

<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/3c9a9391-e48b-4f58-97dc-e173c5b824ef" />


## Lab - Pushing images from your local container registry to Openshift Internal registry


```
podman login -u $(oc whoami) -p $(oc whoami -t) default-route-openshift-image-registry.apps.ocp4.palmeto.org --tls-verify=false
podman pull docker.io/tektutor/spring-ms:1.0
podman images

# In the below replace 'jegan' with your openshift project name
podman tag docker.io/tektutor/spring-ms:1.0 default-route-openshift-image-registry.apps.ocp4.palmeto.org/jegan/spring-ms/jegan/spring-ms:1.0
podman images

podman push default-route-openshift-image-registry.apps.ocp4.palmeto.org/jegan/spring-ms:1.0 --tls-verify=false
oc project jegan
oc get imagestreams
```
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/aff30370-62fa-4750-8710-32b4123c720e" />
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/0c0d5cfe-6773-457e-857b-205b82dfb134" />
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/8834e622-c766-4827-ab9a-486154e3ddc8" />


## Lab - Creating a Openshift secret to store your Docker Hub Login credentials
```
# The below command on successful login, creates a ~/.docker/config.json file
docker login -u your-user

# First approach
oc create secret generic my-docker-account-secret \
--from-file=.dockerconfigjson=~/.docker/config.json \
--type=kubernetes.io/dockerconfigjson

# Second approach
oc create secret docker-registry my-docker-account-secret \
--docker-server=docker.io \
--docker-username=your-dockerhub-username \
--docker-password=your-dockerhub-password \
--docker-email=your-dockerhubregistered-email 

oc screts link default my-docker-account-secret --for=pull
```

## Lab - Configuring certain Openshift nodes for QA, Dev use

Let's list all nodes
```
oc get nodes --show-labels
```

Add a label to mark a node reserved for QA team usage
```
oc label node worker01.ocp4.palmeto.org environment=qa
```

Add a label to mark a node reserved for Dev team usage
```
oc label node worker02.ocp4.palmeto.org environment=dev

```
Verify the nodes marked for QA team's use
```
oc get nodes --show-labels | grep environment=qa
```

Verify the nodes marked for Dev team's use
```
oc get nodes --show-labels | grep environment=dev
```

To prevent non-QA workloads from scheduling on worker01 node
```
oc adm taint nodes worker01.ocp4.palmeto.org qa=only:NoSchedule
oc adm taint nodes worker-qa-02 qa=only:NoSchedule
```

To prevent non-Dev workloads from scheduling on worker02 node
```
oc adm taint nodes worker02.ocp4.palmeto.org dev=only:NoSchedule
```

Add tolerations in QA deployments
```
spec:
  tolerations:
  - key: "qa"
    operator: "Equal"
    value: "only"
    effect: "NoSchedule"
  nodeSelector:
    environment: qa
```

Add tolerations in Dev deployments
```
spec:
  tolerations:
  - key: "dev"
    operator: "Equal"
    value: "only"
    effect: "NoSchedule"
  nodeSelector:
    environment: dev
```

Alternatively, let's use Node affinity
```
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: environment
          operator: In
          values:
          - qa
```

## Lab - Draining a node for maintenance

Prevents new pods getting scheduled in to worker01
```
oc adm cordon worker01.ocp4.palmeto.org
```

Drain the node
```
oc adm drain worker01.ocp4.palmeto.org --ignore-daemonsets --delete-emptydir-data
```

Once you are done with node maintenance
```
oc adm uncordon worker01.ocp4.palmeto.org
```
