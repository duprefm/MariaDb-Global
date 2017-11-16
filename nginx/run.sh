#!/bin/bash

sed -i 's/template/'"$app_name"'/g' /etc/nginx/nginx.conf
