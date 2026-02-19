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


## Lab - Creating an user group, add users to group, restrict access to project

Let's login as administrator
```
oc login $(oc whoami --show-server) -u jegan-admin -p admin@123 --insecure-skip-tls-verify=true
```

Create a group called
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
