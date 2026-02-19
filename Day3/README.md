# Day 3

## Info - Creating and Managing Users,Groups in OpenShift
<pre>
- Authentication in OpenShift is managed by authentication operator
- authentication operator runs an oauth-server
- oauth-server is where the users obtain oauth access token to authenticate into the API
- oauth server can be configured to use identify providers such as htpasswd, LDAP, GitLab, etc.,  
</pre>

## Demo - Installing htpassword utility in Ubuntu ( I have already installed this on both servers - so you can skip. Just for your reference)
```
sudo apt install -y apache2-utils
```

## Lab - Creating and Managing Users,Groups in OpenShift 
```
# This must be used only the first time, since I have already created you don't run this command
# If you run this command by mistake, it is going to delete all the other users
htpasswd -cBb /tmp/htpasswd jegan-admin admin@123
cat /tmp/htpasswd

htpasswd -Bb /tmp/htpasswd jegan-dev dev@123
cat /tmp/htpasswd

cat ~/openshift.txt

oc login $(oc whoami --show-server) -u kubeadmin -p xkHzc-Pv36w-NcB5W-EwAd3 --insecure-skip-tls-verify=true

oc create secret generic htpasswd-secret --from-file htpasswd=/tmp/htpasswd -n openshift-config
oc get oauth cluster -o yaml > oauth.yml
```
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/d424a405-b923-4d04-97d9-08f9461d3b5b" />


Edit the oauth.yml
<pre>
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: palmeto-users
    mappingMethod: claim
    type: HTPasswd
    htpasswd:
      fileData:
        name: htpasswd-secret
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
cat ~/openshift.txt
oc login $(oc whoami --show-server) -u kubeadmin -p xkHzc-Pv36w-NcB5W-EwAd3 --insecure-skip-tls-verify=true
oc adm policy add-cluster-role-to-user cluster-admin jegan-admin
oc login -u jegan-admin -p admin@123
oc get pods
oc get svc
oc get nodes
oc get users
oc get identity
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
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/87e7c012-a1da-4b94-a344-1bc0825bb238" />
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/3493cd7b-6b05-44ad-9d5f-985c779c0639" />


## Info - OpenLDAP 
<pre>
- is an opensource software commonly used in Linux distributions
- LDAP - Lightweight Directory Access Protocol
- distributed directory informaiton services over IP
- Supports Centralized User and Identity Management
  - User Authentication
    - User and respective credentials will be stored in LDAP server
    - When we attempt to login to some software with LDAP Integration, the LDAP server will verify login and authenticates
  - Authorization
    - LDAP stores information about user's roles and group mememberships
    - LDAP determines what permission a user has 
    - RBAC - Role-Based Access Control
  - Single Sign-ON(SSO)
</pre>

## Demo - Integrating LDAP with Red Hat Openshift ( Bonus Topic )

Install OpenLDAP in Ubuntu
```
sudo apt update
sudo apt install slapd ldap-utils
```

Configure OpenLDAP
```
# Reconfigure slapd for proper setup
sudo dpkg-reconfigure slapd
```

Start OpenLDAP Server
```
sudo systemctl status slapd
sudo systemctl enable slapd
sudo systemctl start slapd
sudo systemctl status slapd
```

Create LDAP structure and users (LDIF file)
```
dn: ou=people,dc=palmeto,dc=org
objectClass: organizationalUnit
ou: people

dn: ou=groups,dc=palmeto,dc=org
objectClass: organizationalUnit
ou: groups
```

Create a user
```
dn: uid=jegan,ou=people,dc=palmeto,dc=org
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: jegan
sn: Swaminathan
givenName: Jeganathan
cn: Jeganathan Swaminathan
displayName: Jeganathan Swaminathan
uidNumber: 1001
gidNumber: 1001
userPassword: {SSHA} root@123
gecos: Jeganathan Swaminathan
loginShell: /bin/bash
homeDirectory: /home/jegan
```

Add the user
```
ldapadd -x -D "cn=admin,dc=palmeto,dc=org" -W -f /tmp/base.ldif
ldapadd -x -D "cn=admin,dc=palmeto,dc=org" -W -f /tmp/user.ldif
```

Configure Ubuntu firewall to allow LDAP
```
sudo ufw allow 389
```

Integrate OpenLDAP with OpenShift v4.21 (ldap-idp.yaml)
```
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: ldap
    mappingMethod: claim
    type: LDAP
    ldap:
      attributes:
        id:
        - dn
        preferredUsername:
        - uid
        name:
        - cn
        email: []
      bindDN: "cn=admin,dc=palmeto,dc=org"
      bindPassword:
        name: ldap-secret
      insecure: true
      url: "ldap://192.168.10.200:389/ou=people,dc=palmeto,dc=org?uid/sub"
```

Create LDAP bind password secret
```
oc create secret generic ldap-secret \
  --from-literal=bindPassword=root@123 \
  -n openshift-config
```

Let's enable LDAPS(636) in OpenLDAP
Generate self-signed certificate
```
mkdir -p /etc/ldap/certs

openssl req -new -x509 -nodes -days 365 \
-out /etc/ldap/certs/ldap.crt \
-keyout /etc/ldap/certs/ldap.key

ls /etc/ldap/certs/

chown -R openldap:openldap /etc/ldap/certs
```

Create a tls.ldif
<pre>
dn: cn=config
changetype: modify
replace: olcTLSCertificateFile
olcTLSCertificateFile: /etc/ldap/certs/ldap.crt
-
replace: olcTLSCertificateKeyFile
olcTLSCertificateKeyFile: /etc/ldap/certs/ldap.key  
</pre>

Configure TLS
```
ldapmodify -Y EXTERNAL -H ldapi:/// -f tls.ldif
```

Enable LDAPS in slapd, edit the /etc/default/slapd
```
SLAPD_URLS="ldap:/// ldapi:/// ldaps:///"
systemctl restart slapd
systemctl status slapd
sudo ss -tulnp | grep 636
sudo journalctl -xe | grep slapd
```

<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/9b7b181c-5406-4e5a-8ceb-eaf93b21dd44" />


Create LDAP server certificate
```
# Get LDAP server certificate
openssl s_client -connect 192.168.10.200:636 -showcerts < /dev/null 2>/dev/null | openssl x509 -outform PEM > ldap-ca.crt

# Create configmap
oc create configmap ldap-ca \
  --from-file=ca.crt=ldap-ca.crt \
  -n openshift-config
```

Create the LDAP Identify Provider Configuration
```
oc apply -f ldap-idp.yaml
```

Create ClusterRoleBinding for LDAP users
```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ldap-cluster-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: jegan
```
```
oc apply -f /tmp/ldap-admin-binding.yml
```

Verify the integration
```
#Update password
ldappasswd -x -H ldap://192.168.10.200:389 -D "cn=admin,dc=palmeto,dc=org" -W -S "uid=jegan,ou=people,dc=palmeto,dc=org"

# Test authentication after password update
ldapwhoami -x -H ldap://192.168.10.200:389 -D "uid=jegan,ou=people,dc=palmeto,dc=org" -W
# Enter password: root@123

#Alternate approach
slappasswd -s "root@123"

# Check OAuth configuration
oc get oauth cluster -o yaml | grep -A 20 "ldap:"

# Check authentication operators
oc get pods -n openshift-authentication-operator

# If still showing ldaps://, reapply the configuration
oc apply -f /tmp/ldap-non-ssl.yaml

# Wait for OAuth configuration to propagate (2-3 minutes)
sleep 180

# Try OpenShift login
oc login --username=jegan --password='root@123' --insecure-skip-tls-verify

# In another terminal, monitor authentication attempts
oc logs -n openshift-authentication deployment/oauth-openshift -f | grep -E "(jegan|ldap|bind|authentication|error)"
```

## Lab - Deploying an application from GitHub source using docker strategy
```
oc project jegan
oc new-app https://github.com/tektutor/spring-ms.git --strategy=docker
```


## Info - Getting used to Red Hat Openshift Webconsole
In the terminal run the below command
```
oc whoami --show-console
```

Open the webconsole url
```
https://console-openshift-console.apps.ocp4.palmeto.org
```

Red Hat Openshift Webconsole presents you a overview as shown below
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/8f2fa4db-4502-4e74-a314-49f1af05838c" />

All the Projects can be viewed in this page
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/f6a16cf5-605f-4903-9b51-82c940067248" />

You may choose your project, in my case I clicked on my project 'jegan'
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/4b26b31c-7196-49ab-a0b6-025eea216885" />
In this page, you can see the inventory or resources under your project. You can also observe the performance metrics.
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/1a5f7134-de65-4c87-b525-451dd41eaaeb" />

You may check the Project details 
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/59a70fe5-bc43-44e7-b179-e1254d4eed36" />

Project yaml definition can be found here
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/0aeb61e0-0bdb-4912-84ca-a9fbe45aa208" />

Under Workloads Tab, you can see Deployments, DaemonSet, Job, CronJob, StatefulSet, etc
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/9dbf6b07-9f1b-426c-ac32-f5bce1df845f" />
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/742cc136-6848-4a90-8793-ef44c3d77621" />

You may click on one of the Pods on the right side to see the Pod details
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/7cbbc901-8b7c-4b37-be3f-6ab1cd359d00" />

You can see the Pod performance metrics in this tab
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/15470a56-9afa-4e35-bddd-d8eb08c5d2d0" />

Pod yaml definition can be seen here
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/a1807ce4-58b7-41f0-b531-26158260f91f" />

Pod environment variables can be seen here
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/fb1b5f4a-56c5-468e-9279-38f233b7e491" />

Pod logs can be seen here
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/31ee32e8-89e9-4392-b556-2d6e8203c3db" />

Pod events can be seen here
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/ef86f41a-a79a-41b0-9c66-ace3082ee766" />

You can get into the Pod terminal as shown below
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/71ca5de2-eef2-4a1f-a8a7-0e01f3d1d4b3" />

You can search any resources in this page
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/1b8b80cb-cd9d-4030-905e-6e7b69deff62" />

API Explorer shows one liner definition of every Openshift resources, and the respective API Group and version.
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/0b775feb-e7a7-453d-a8df-b538c6863a62" />

Project wide events can be seen here
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/981b74ed-5104-485c-920e-6b1225bbc1b6" />

You can deploy applications from the Software Catalog
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/566186eb-47ec-4275-a150-6b258e3b0ad3" />

You can see all the operators installed in the Openshift cluster from this page
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/cc3ea7c2-26eb-4a8f-bc2c-5fb9e20a09fc" />

From this Helm page, you can see applications deployed using Helm Package manager
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/6530447a-fb9e-4bf3-b37f-442e98258fca" />

Topology shows the applications deployed in your project
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/08a99a13-f248-42e8-b192-2bd912004212" />

In this page, you can see all the Pods deployed in the selected project
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/fc2fc32f-f067-42cf-a224-a852e3488a03" />

All the Deployments under the selected project can be viewed and managed from here
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/309a79c4-8f9d-426c-af4d-a14762fdfe87" />

DeploymentConfigs is deprecated in Openshift as Deployment replaces the DeploymentConfigs and ReplicationControllers
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/511505fc-0234-44a2-84f2-1f25ccc84536" />

StatefulSet application deployments can be viewed and managed from this page
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/dcd0446f-4383-4bca-bbfb-46f40031f340" />

Login credentials, certs which are sensitive(confidential) can be stored and managed in secrets in this page
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/be2e7d85-b995-4e10-83eb-1cc78be58ea0" />

Any non-sensitive configuration details are maintained in ConfigMap as key/value. Configmaps can be viewed and managed from here
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/8020ed2e-5b77-48ea-bf7a-12c42b2b570d" />

Any jobs that must be scheduled and executed on a particular day/time with frequency can be managed here
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/72ca263b-a085-4d7a-baef-20994a914b6d" />

Any one time job can be managed here
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/51fd7d44-915f-4517-b0a8-f0db2e54115d" />

DaemonSet let's you deploy one pod per node.  You can manage DaemonSet from here
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/88f59e10-8bb4-423a-b967-50aa14ea26f9" />

ReplicaSets that are created as part of Deployments can be viewed and managed from here
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/457e5ca9-e632-4c14-8e5e-60d0082a3d4e" />

ReplicationControllers are deprecated in new versions of Openshift.  Deployment replaces ReplicationControllers.
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/86296b21-877f-4cbd-9b6a-bd25de85c289" />

Pod auto scale configurations can be done from here
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/017fd861-b92c-4dc8-a22e-6585a51b780c" />

Pod disruption budget tells how many minimal pods must run during Openshift maintenance
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/c14e9da9-0a9b-49a2-b1ae-33f73488cec3" />

Under Networking --> Services one can all the services like ClusterIP, NodePort and LoadBalancer 
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/f24e2a65-d626-4cd1-8bf0-7ea0fc1fd359" />

Routes that exposes an applicaiton for external use can be seen here
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/604bf2f9-a832-4b16-a62a-001af8e70b17" />

Ingress forwarding rules can be seen here
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/490bd23c-4302-4cd3-881b-872ec8aa88b7" />

Network Policies can be seen here
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/dda1aeca-21c8-44bd-b921-00bad8657cd1" />

Persistent Volumes - external storage volumes(disks) can be viewed and managed from here
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/d0a73a24-35e1-4a29-92d9-e1d39feac7f9" />

Applications that need external persistent storage(disk) request for external storage using Persistent Volume Claims from here.  You can manage Persistent Volume Claims from here
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/2ceaf976-c502-46fb-99ef-34e4f4bf0262" />

S2I - Source to Image depends on BuildConfig to that builds an application binary, build custom container image to deploy application 
into Openshift from source code from Version controls.
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/cc0724ed-2afd-4e26-b9d7-c25c2e4c7bdc" />

Build is an instance of Build Config, applications are built to repective executable and custom images are built inside Build Pods 
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/88c02541-a225-490f-9a2f-111e6041df75" />

All the images that were used to deploy applications in your project and the custom images created by S2I builds can be viewed here
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/54dfee5a-202a-4f2b-b0c6-ee7233dfbc63" />

Here you could see all performance metrics
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/b791bf01-3ee5-4d06-b1a3-1c267cbd9dde" />

Node details can be viewed here
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/f27d3e98-e2a7-4a6a-8cbc-e0a4ce72fb8b" />

Users and groups can be managed and viewd here
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/3ffbcfef-b20d-4f6f-8ff4-383333fe8ff3" />


