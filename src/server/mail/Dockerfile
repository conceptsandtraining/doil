FROM debian:stable

# base
RUN apt-get update
RUN apt-get install -y supervisor
RUN apt-get install -y vim less virt-what net-tools procps git debconf-utils
RUN apt-get install -y apache2 mariadb-server php-mysql
#RUN apt-get install -y postfix
#RUN apt-get install -y dovecot-core dovecot-imapd

# roundcube
RUN rm /var/www/html/index.html
RUN cd /var/www/html && git clone https://github.com/roundcube/roundcubemail.git .

#RUN touch /etc/mailname
#RUN echo "locahost" >> /etc/mailname
#RUN chmod 777 /var/mail

EXPOSE 25 80 110 143 465 587 993 995

COPY conf/run-supervisor.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/run-supervisor.sh
CMD ["/usr/local/bin/run-supervisor.sh"]
