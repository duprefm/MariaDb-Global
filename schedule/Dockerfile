FROM ubuntu:16.04

ADD crontab /etc/cron.d/hello-cron
 
RUN chmod 0644 /etc/cron.d/hello-cron
 
RUN touch /var/log/cron.log

RUN apt-get -y install -qq --force-yes cron
 
CMD ["/usr/sbin/cron", "-f"]
