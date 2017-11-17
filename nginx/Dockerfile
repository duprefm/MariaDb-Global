FROM nginx

COPY nginx_template.conf /etc/nginx/nginx.conf

COPY run.sh /run.sh

RUN chmod +x /run.sh

ENTRYPOINT /run.sh

EXPOSE 80

STOPSIGNAL SIGTERM

CMD ["nginx", "-s"]
