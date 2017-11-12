#!/bin/bash

echo "$node1 : $node2 : $node3"

if [ "$node1" == "node1" ]
then
	node1="node1"
else
	node1="$node1"
fi

if [ "$node2" == "node2" ]
then
        node2="node2"
else
        node2="$node2"
fi

if [ "$node3" == "node3" ]
then
        node3="node3"
else
        node3="$node3"
fi

cat /etc/nginx/nginx.conf | sed -e "s/node1/"${node1}"/g" -e "s/node2/"${node2}"/g" -e "s/node3/"${node3}"/g" > /etc/nginx/nginx.conf.new
mv /etc/nginx/nginx.conf.new /etc/nginx/nginx.conf
service nginx start
#sed -i 's/node1/'"$node1"'/g' /etc/nginx/nginx.conf 
#sed -i 's/node2/'"$node2"'/g' /etc/nginx/nginx.conf 
#sed -i 's/node3/'"$node3"'/g' /etc/nginx/nginx.conf 
