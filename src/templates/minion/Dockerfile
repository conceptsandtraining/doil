FROM debian:stable

RUN apt-get update
RUN apt-get install -y salt-minion supervisor

RUN usermod -u %USER_ID% www-data
RUN groupmod -g %GROUP_ID% www-data

COPY conf/run-supervisor.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/run-supervisor.sh
CMD ["/usr/local/bin/run-supervisor.sh"]
