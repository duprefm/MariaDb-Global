FROM nginx

COPY nginx_template.conf /etc/nginx/nginx.conf

COPY run.sh /run.sh

RUN chmod 755 /run.sh

ARG node1=GALERACLUSTER_node1
ARG node2=GALERACLUSTER_node2
ARG node3=GALERACLUSTER_node3
ENV node1=$node1
ENV node2=$node2
ENV node3=$node3

RUN /run.sh
