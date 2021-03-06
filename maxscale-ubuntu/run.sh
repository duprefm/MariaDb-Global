#!/bin/bash

echo $address1  address1 >> /etc/hosts
echo $address2  address2 >> /etc/hosts
echo $address3  address3 >> /etc/hosts

sed -i 's/user=user/user='"$user"'/g' /usr/local/skysql/maxscale/etc/MaxScale.cnf
sed -i 's/passwd=passwd/passwd='"$passwd"'/g' /usr/local/skysql/maxscale/etc/MaxScale.cnf
sed -i 's/address=address1/address='"$address1"'/g' /usr/local/skysql/maxscale/etc/MaxScale.cnf
sed -i 's/address=address2/address='"$address2"'/g' /usr/local/skysql/maxscale/etc/MaxScale.cnf
sed -i 's/address=address3/address='"$address3"'/g' /usr/local/skysql/maxscale/etc/MaxScale.cnf

#sleep 300
#/usr/bin/maxscale -f /usr/local/skysql/maxscale/etc/MaxScale.cnf
