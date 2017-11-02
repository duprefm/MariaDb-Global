FROM dtr-v-rr.docker.opteama.net:443/stelia/mariadb:latest 

#RUN apt-get update && apt-get upgrade -y \
#    && rm -rf /var/lib/apt/lists/*
    
COPY init_cluster_conf.sh /docker-entrypoint-initdb.d/init_cluster_conf.sh
COPY init_galera_user.sh /docker-entrypoint-initdb.d/init_galera_user.sh
COPY init_galera_user.sql /docker-entrypoint-initdb.d/init_galera_user.sql

# we need to touch and chown config files, since we cant write as mysql user
RUN touch /etc/mysql/conf.d/galera.cnf \
    && chown mysql.mysql /etc/mysql/conf.d/galera.cnf \
    && chown mysql.mysql /docker-entrypoint-initdb.d/*.sql

EXPOSE 3306 4444 4567 4568

# we set some defaults
ENV GALERA_USER=galera \
    GALERA_PASS=galerapass \
    MAXSCALE_USER=maxscale \
    MAXSCALE_PASS=maxscalepass \ 
    CLUSTER_NAME=docker_cluster \
    MYSQL_ALLOW_EMPTY_PASSWORD=1
    
CMD ["mysqld"]
