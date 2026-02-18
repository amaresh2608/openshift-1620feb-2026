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

## Demo - Install OpenLDAP in Ubuntu (Just for your reference, please don't attempt this in our lab environment )
```
sudo apt update
sudo apt install slapd ldap-utils -y
```


Configuring LDAP Server
<pre>
sudo dpkg-reconfigure slapd  
</pre>

How to respond when the above commands prompts your response
<pre>
Omit OpenLDAP server configuration?	No
DNS domain name?	palmeto.org
Organization name?	Palmeto
Administrator password?	palmeto@123
Database backend?	MDB
Remove database when slapd is purged?	No
Move old database?	Yes
</pre>

Check if LDAP Server is running
```
sudo systemctl status slapd
sudo ss -tulnp | grep :389
```

Check if LDAP search works
```
ldapsearch -x -LLL -H ldap://localhost -b dc=palmeto,dc=org
```

Create a file named base.ldif
<pre>
dn: ou=users,dc=palmeto,dc=org
objectClass: organizationalUnit
ou: users

dn: ou=groups,dc=palmeto,dc=org
objectClass: organizationalUnit
ou: groups  
</pre>

Apply the above configuration
```
ldapadd -x -D "cn=admin,dc=palmeto,dc=org" -W -f base.ldif
```

Add LDAP users, creat a file named users.ldif
<pre>
dn: uid=jegan,ou=users,dc=palmeto,dc=org
objectClass: inetOrgPerson
uid: jegan
sn: Swaminathan
cn: Jeganathan Swaminathan
mail: jegan@tektutor.org
userPassword: palmeto@123

dn: cn=admins,ou=groups,dc=palmeto,dc=org
objectClass: groupOfNames
cn: admins
member: uid=jegan,ou=users,dc=palemto,dc=org  
</pre>

Create the user
```
ldapadd -x -D "cn=admin,dc=palmeto,dc=org" -W -f users.ldif
```

Search users
```
ldapsearch -x -LLL -b "ou=users,dc=palmeto,dc=org"
```

Search groups
```
ldapsearch -x -LLL -b "ou=groups,dc=palmeto,dc=org"
```

Configure Ubuntu firewall to allow LDAP
```
sudo ufw allow 389
```

LDAP Server details
<pre>
Base DN : dc=palmeto,dc=org
Admin DN: cn=admin,dc=palmeto,dc=org
User DN	: uid=jegan,ou=users,dc=palmeto,dc=org
Group DN: cn=admins,ou=groups,dc=palmeto,dc=org
Password: palmeto@123
</pre>

Script to extract existing linux users and add them as users in LDAP server
```
#!/bin/bash

# Hashed value of "palmeto@123" using slappasswd
LDAP_PASS="{SSHA}Xky2OjkOZt5U4eebv9rWsk9VUYR6Fa9Z"

# Output LDIF file
OUTPUT_FILE="palmeto-ldap-users.ldif"
> "$OUTPUT_FILE"

for user in $(ls -l /home | awk '{print $3}' | sort -u); do
    # Get user details from /etc/passwd
    IFS=':' read -r username _ uid gid full home shell <<< "$(getent passwd "$user")"

    # Skip if user not found
    [ -z "$username" ] && continue

    # Set default values for cn and sn
    if [ -z "$full" ]; then
        cn="$username"
        sn="user"
    else
        cn=$(echo "$full" | cut -d' ' -f1)
        sn=$(echo "$full" | cut -d' ' -f2)
        [ -z "$cn" ] && cn="$username"
        [ -z "$sn" ] && sn="user"
    fi

    # Set email from username
    email="${username}@palmeto.org"

    cat <<EOF >> "$OUTPUT_FILE"
dn: uid=$username,ou=users,dc=palmeto,dc=org
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
cn: $cn
sn: $sn
uid: $username
uidNumber: $uid
gidNumber: $gid
homeDirectory: $home
loginShell: $shell
mail: $email
userPassword: $LDAP_PASS

EOF
done

echo "LDIF file generated: $OUTPUT_FILE"
```

In case you wish to delete existing users from LDAP server before adding the below users
```
ldapsearch -LLL -x -D "cn=admin,dc=palmeto,dc=org" -w 'palmeto@123' -b "ou=users,dc=palmeto,dc=org" "(objectClass=inetOrgPerson)" dn \
  | grep '^dn:' \
  | sed 's/^dn: //' \
  | xargs -n1 ldapdelete -x -D "cn=admin,dc=palmeto,dc=org" -w 'palmeto@123'
```

Let's add the ldap users now
```
ldapadd -x -D "cn=admin,dc=palmeto,dc=org" -W -f palmeto-ldap-users.ldif
```

Let's create an openshift secret
```
oc create secret generic ldap-secret \
  --from-literal=bind_dn='cn=admin,dc=palmeto,dc=org' \
  --from-literal=bind_password='palmeto@123' \
  -n aap
```
