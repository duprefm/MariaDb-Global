#!/bin/bash

echo $address1  address1 >> /etc/hosts
echo $address2  address2 >> /etc/hosts
echo $address3  address3 >> /etc/hosts

sed -i 's/user=$user/user='"$user"'/g' /usr/local/skysql/maxscale/etc/MaxScale.cnf
sed -i 's/passwd=$passwd/passwd='"$passwd"'/g' /usr/local/skysql/maxscale/etc/MaxScale.cnf
sed -i 's/address1=GALERACLUSTER_node1
      - address2=GALERACLUSTER_node2
      - address3=GALERACLUSTER_node3
      - user=cluster
      - passwd=clusterpass
      - MYSQL_DATABASE=test
      - MYSQL_USER=test_user

sleep 300
#/usr/bin/maxscale -f /usr/local/skysql/maxscale/etc/MaxScale.cnf
