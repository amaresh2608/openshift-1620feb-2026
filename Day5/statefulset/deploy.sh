echo -n "\nDeploying mysql primary master ...."
oc create -f mysql-secret.yml --save-config
oc create -f mysql-primarymaster-service.yml --save-config

echo -n "\nDeploying mysql replica slaves ..."
oc create -f mysql-sfs1.yml
oc create -f mysql-sfs2.yml
oc create -f mysql-service.yml
