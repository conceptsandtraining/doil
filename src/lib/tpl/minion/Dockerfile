FROM debian:stable

RUN apt-get update
RUN apt-get install -y vim supervisor salt-minion

COPY conf/run-supervisor.sh /var/www
RUN chmod +x /var/www/run-supervisor.sh
CMD ["/var/www/run-supervisor.sh"]
