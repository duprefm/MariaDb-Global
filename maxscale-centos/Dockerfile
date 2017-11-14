FROM centos:7

RUN yum install -y wget

RUN wget https://downloads.mariadb.com/MaxScale/2.1.10/rhel/7/x86_64/maxscale-2.1.10-1.rhel.7.x86_64.rpm 

RUN yum localinstall -y /maxscale-2.1.10-1.rhel.7.x86_64.rpm && yum clean all

RUN rm -f /maxscale-2.1.10-1.rhel.7.x86_64.rpm

COPY maxscale.cnf /etc/maxscale.cnf

COPY run.sh /run.sh

RUN chmod 755 /run.sh

EXPOSE 3306

CMD ["/run.sh"]
