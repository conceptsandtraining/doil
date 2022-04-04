FROM debian:stable

# base
RUN apt-get update
RUN apt-get install -y supervisor salt-minion
RUN apt-get install -y vim less virt-what net-tools procps git debconf-utils

# TODO give www-data passwd
#RUN touch /var/mail/www-data
#RUN mkdir -p /var/www/mail
#RUN chown -R www-data:mail /var/mail/www-data
#RUN chown -R www-data:mail /var/www/mail

EXPOSE 80 143 465 587 993 995

COPY conf/run-supervisor.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/run-supervisor.sh
CMD ["/usr/local/bin/run-supervisor.sh"]
