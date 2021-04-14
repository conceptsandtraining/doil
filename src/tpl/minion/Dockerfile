FROM debian:stable

RUN apt-get update
RUN apt-get install -y salt-minion supervisor

COPY conf/run-salt-minion.sh /usr/local/bin/run-salt-minion.sh
RUN chmod a+x /usr/local/bin/run-salt-minion.sh
CMD ["/usr/local/bin/run-salt-minion.sh"]

COPY conf/run-supervisor.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/run-supervisor.sh
CMD ["/usr/local/bin/run-supervisor.sh"]
