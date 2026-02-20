echo -n "\nDeploying mysql primary master ...."
oc apply -f mysql-secret.yml
oc apply -f mysql-primarymaster-service.yml

echo -n "\nDeploying mysql replica slaves ..."
oc apply -f mysql-sfs1.yml
oc apply -f mysql-sfs2.yml
oc apply -f mysql-service.yml
