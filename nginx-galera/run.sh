#!/bin/bash

if [ ! -z "$node1" ]
then
	"node1"="GALERACLUSTER_node1"
	sed -i 's/node1/'"$node1"'/g' /etc/nginx/nginx.conf 
else
	"node1"="$node1"
	sed -i 's/node1/'"$node1"'/g' /etc/nginx/nginx.conf 
fi

sed -i 's/node1/'"$node1"'/g' /etc/nginx/nginx.conf 
sed -i 's/node2/'"$node2"'/g' /etc/nginx/nginx.conf 
sed -i 's/node3/'"$node3"'/g' /etc/nginx/nginx.conf 
