#!/bin/bash

sed -i 's/node1/'"$node1"'/g' /etc/nginx/nginx.conf 
sed -i 's/node2/'"$node2"'/g' /etc/nginx/nginx.conf 
sed -i 's/node3/'"$node3"'/g' /etc/nginx/nginx.conf 
