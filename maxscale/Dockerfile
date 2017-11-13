FROM ubuntu:16.04 

RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install wget -y
RUN apt-get install libcurl3 -y

RUN wget https://downloads.mariadb.com/MaxScale/2.0.6/ubuntu/dists/xenial/main/binary-amd64/maxscale-2.0.6-1.ubuntu.xenial.x86_64.deb
#RUN wget https://downloads.mariadb.com/MaxScale/2.1.10/ubuntu/dists/xenial/main/binary-amd64/maxscale-2.1.10-1.ubuntu.xenial.x86_64.deb 

RUN apt-get update

#RUN dpkg -i maxscale-2.1.10-1.ubuntu.xenial.x86_64.deb
RUN dpkg -i maxscale-2.0.6-1.ubuntu.xenial.x86_64.deb 

RUN apt-get install -f

COPY MaxScale.cnf /usr/local/skysql/maxscale/etc/MaxScale.cnf

COPY run.sh /run.sh

RUN chmod 755 /run.sh

RUN rm -f /maxscale-2.0.6-1.ubuntu.xenial.x86_64.deb

ENTRYPOINT ["/run.sh"]

EXPOSE 3306

CMD ["/usr/bin/maxscale -f /usr/local/skysql/maxscale/etc/MaxScale.cnf"]
