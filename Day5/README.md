# Day 5

## Lab - Cloning TekTutor Training Repository ( In case you haven't done already )
```
cd ~
git clone https://github.com/tektutor/openshift-1620feb-2026.git
cd openshift-1620feb-2026
```

## Lab - Deploying NodeJS Application from Openshift Webconsole
```

```

## Lab - Deploying ReactJS Application from CLI
```
```

## Info - Installing NFS Server in Ubuntu
```
sudo apt install -y nfs-kernel-server
sudo systemctl start nfs-kernel-server.service
sudo apt install -y nfs-common
sudo systemctl restart nfs-kernel-server
sudo systemctl enable nfs-kernel-server
```

## Info - Peristent Volume (PV)
<pre>
- are external Storage Disks provisioned by System Administrators
- PVs can be provisioned either manually or dynamically using storeclass from NFS, AWS, Azure, etc.,
- PV usually will have the below attributes
  - nfs server
  - nfs shared path
  - volumeMode
  - storageclass
  - accessmode - ReadWriteOnce, ReadWriteMany, etc.,
  - storage size
  - any optional labels - to ensure only the requested team is able to claim this storage
</pre>  

## Info - Persistent Volume Claim (PVC)
<pre>
- any application that needs external storage, they must request for storage by creating a PVC
- PVC is created with project scope
- PVC attributes
  - volumeMode
  - accessMode
  - storage size
  - any option label selector - to claim a PV that matches the label
</pre>  

## Let's deploy a multi-pod wordpress application along with db that uses PV and PVCs from NFS server
```
cd ~/openshift-1620feb-2026
git pull
cd Day5/wordpress-with-configmaps-and-secrets
ls
./deploy.sh
oc get pods
oc logs -f 
```
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/e63c398c-1eb3-42a5-9d64-722fef08c9cf" />
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/fa9ae15c-fdc8-4864-8d4f-0eb6103069f6" />
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/3fb79090-a204-496a-a50e-c75731146cb1" />
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/d56e1556-310f-4727-b3b3-d278b3973f0b" />
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/696760f7-0a51-4db2-b3a7-b3ed9380c932" />
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/cf2548e4-ba88-4f35-9460-f5c9f16f4f17" />

Once you are done with this exercise, you can dicard the resources
```
cd ~/openshift-1620feb-2026
cd Day5/wordpress-with-configmaps-and-secrets
ls
oc get deploy,rs,po,svc,route,pv,pvc,cm,secrets
./undeploy.sh
oc get deploy,rs,po,svc,route,pv,pvc,cm,secrets
```
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/57f5734f-2a5a-4acb-a895-79c38fe35ec3" />
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/0417f135-ae86-4399-975e-2f56e0be1b3e" />
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/dbdf0a69-b25e-46d4-b52b-04ff531fa70f" />

## Lab - Creating a LoadBalancer external service
```
oc delete project jegan
oc new-project jegan

oc create deploy nginx --image=image-registry.openshift-image-registry.svc:5000/openshift/nginx:1.29 --replicas=3
oc get pods

# Create a loadbancer external service
oc expose deploy/nginx --port=8080 --type=LoadBalancer
oc get svc
oc describe svc/nginx

curl http://192.168.100.50:8080
```
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/54357b31-1d4e-4eb2-b132-686456e3b744" />
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/045297a6-238a-491d-a8c2-a2230d61f3aa" />
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/c4521b0c-d8aa-4c76-b71f-be074d524a81" />

## Info - Helm
<pre>
- Helm is a package manager for Kubernetes and Openshift Container Orchestration Platforms
- Using Helm we can deploy,undeploy, upgrade applications into Kubernetes and Openshift
- We need to package our Openshift manifest scripts as Helm chart in order to deploy/undeploy into K8s/Openshift
</pre>  

## Lab - Packaging wordpress application as Helm Chart
```
cd ~/openshift-1620feb-2026
git pull
cd Day5/helm

# Create a helm chart
helm create wordpress
cd wordpress/templates
rm -rf *
cd ../..
cp values.yaml wordpress
cp manifest-scripts/* wordpress/templates

# Create the helm chart package
tree wordpress/
helm package wordpress/
ls

# Install the wordpress helm chart into openshift
oc delete project jegan
oc new-project jegan
helm install wordpress wordpress-1.0.0.tgz

# List the helm releases
helm list
oc get pods

# You can now switch to your Openshift webconsole and access the route url to see the blog
```
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/f9c9f3af-a924-476e-883d-a79d43567431" />
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/4e52915e-fc5a-4348-b0d3-821463d165ac" />
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/ad10963b-e38b-4340-8108-4431e233599c" />

Once you are done with this lab exercise, you may delete it
```
oc project jegan
helm list
oc get pods
helm uninstall wordpress
oc get pods
```
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/dc17e157-4c9b-41b6-aaa7-94a3c7d79af5" />

## Info - Openshift Network Policy
<pre>
- is essentially Kubernetes NetworkPolicy with some OpenShift-specific integrations
- is the primary mechanism for controlling network traffic between pods (and to/from external endpoints) 
  at L3/L4 level (IP addresses, ports, protocols)
- by default, pods in a namespace can talk freely to each other and to the outside world unless some Network Policy prevents it
- When we create a Network Policy for a particular Project(Namespace), all Pods in that Project(Namespace) 
  are isolated from the ingress(incoming) traffic 
- Only traffic that are allowed by explicit Network policiy are permitted 
- Multiple Policies in the same namespace(project) are combined(ORed together) 
</pre>
