#!/bin/bash

echo $app_name

sed -i 's/template/'"$app_name"'/g' /etc/nginx/nginx.conf

#nginx -s reload -c /etc/nginx/nginx.conf
nginx -c /etc/nginx/nginx.conf
