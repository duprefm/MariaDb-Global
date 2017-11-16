#!/bin/bash

echo $app_name

sed -i 's/template/'"$app_name"'/g' /etc/nginx/nginx.conf

/usr/bin/nginx -s reload -c /etc/nginx/nginx.conf
