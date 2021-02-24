FROM debian:stable

RUN apt-get update
RUN apt-get install -y vim less procps supervisor salt-master

COPY run-supervisor.sh /usr/local/bin/run-supervisor.sh
RUN chmod a+x /usr/local/bin/run-supervisor.sh
CMD ["/usr/local/bin/run-supervisor.sh"]
