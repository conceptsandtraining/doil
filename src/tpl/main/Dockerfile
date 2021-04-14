FROM debian:stable

RUN apt-get update
RUN apt-get install -y vim less procps salt-master

COPY run-salt-master.sh /usr/local/bin/run-salt-master.sh
RUN chmod a+x /usr/local/bin/run-salt-master.sh
CMD ["/usr/local/bin/run-salt-master.sh"]

#COPY run-supervisor.sh /usr/local/bin/run-supervisor.sh
#RUN chmod a+x /usr/local/bin/run-supervisor.sh
#CMD ["/usr/local/bin/run-supervisor.sh"]
