FROM nginx

COPY nginx_template.conf /etc/nginx/nginx.conf

COPY run.sh /run.sh

RUN chmod 755 /run.sh

RUN /run.sh
