# Day 4

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

