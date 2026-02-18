# Day 3


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

Integrate OpenLDAP with OpenShift v4.19 (ldap-idp.yaml)
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
        email:
        - mail
      bindDN: "cn=admin,dc=palmeto,dc=org"
      bindPassword:
        name: ldap-secret
      insecure: true
      url: "ldap://192.168.10.200:389/ou=people,dc=palmeto,dc=org?uid"
```

Create LDAP bind password secret
```
oc create secret generic ldap-secret \
  --from-literal=bindPassword=root@123 \
  -n openshift-config
```

Create LDAP server certificate
```
# Get LDAP server certificate
openssl s_client -connect your-ldap-server:636 -showcerts < /dev/null 2>/dev/null | openssl x509 -outform PEM > ldap-ca.crt

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
