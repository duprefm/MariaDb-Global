FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive
ENV INITRD No
ENV LANG en_US.UTF-8

RUN groupadd -r mysql && useradd -r -g mysql mysql

RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y --no-install-recommends gosu vim.tiny wget curl sudo net-tools pwgen git-core logrotate software-properties-common
RUN apt-get clean -y
RUN rm -rf /var/lib/apt/lists/*

## MariaDb
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0xF1656F24C74CD1D8 
RUN echo 'deb http://download.nus.edu.sg/mirror/mariadb/repo/10.2/ubuntu xenial main' | tee /etc/apt/sources.list.d/mariadb.list
RUN apt-get update -y 
RUN apt-get install --no-install-recommends -y mariadb-server -y
RUN sed -i 's/^\(bind-address\s.*\)/# \1/' /etc/mysql/my.cnf
RUN apt-get clean -y
RUN rm -rf /var/lib/apt/lists/*
RUN update-rc.d -f mysql disable

# Percona backups
RUN wget https://repo.percona.com/apt/percona-release_0.1-4.xenial_all.deb
RUN dpkg -i percona-release_0.1-4.xenial_all.deb
RUN apt-get update -y
RUN apt-get install percona-xtrabackup-24 -y

RUN sed -ri 's/^user\s/#&/' /etc/mysql/my.cnf /etc/mysql/conf.d/*
RUN rm -rf /var/lib/mysql
RUN mkdir -p /var/lib/mysql /var/run/mysqld
RUN chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
RUN chmod 777 /var/run/mysqld
RUN mkdir -p /usr/share/zoneinfo
RUN chown -R mysql:mysql /usr/share/zoneinfo
RUN sed -Ei 's/^(bind-address|log)/#&/' /etc/mysql/my.cnf
RUN echo '[mysqld]\nskip-host-cache\nskip-name-resolve' > /etc/mysql/conf.d/docker.cnf

VOLUME /var/lib/mysql

COPY dumpSQL.sh /usr/local/bin/
COPY svgxtrabackup.sh /usr/local/bin/
COPY backup.sh /usr/local/bin/
COPY Maintenance_Bases.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/dumpSQL.sh
RUN chmod +x /usr/local/bin/svgxtrabackup.sh
RUN chmod +x /usr/local/bin/backup.sh
RUN chmod +x /usr/local/bin/Maintenance_Bases.sh

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
RUN chmod 777 /usr/local/bin/docker-entrypoint.sh \
    && ln -s /usr/local/bin/docker-entrypoint.sh /
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

EXPOSE 3306
CMD ["mysqld"]
