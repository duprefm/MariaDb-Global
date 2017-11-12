FROM nginx

COPY nginx_template.conf /etc/nginx/nginx.conf

COPY run.sh /run.sh

RUN chmod 755 /run.sh

ENV node1=$node1
ENV node2=$node2
ENV node3=$node3

RUN /run.sh
