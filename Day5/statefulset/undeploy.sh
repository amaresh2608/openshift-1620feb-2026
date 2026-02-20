echo -n "\nUndeploying mysql replica slaves ..."
oc delete -f mysql-service.yml
oc delete -f mysql-sfs2.yml
oc delete -f mysql-sfs1.yml

echo -n "\nUndeploying mysql primary master ...."
oc delete -f mysql-primarymaster-service.yml
oc delete -f mysql-secret.yml

