FROM debian:stable

RUN apt-get update
RUN apt-get install -y supervisor salt-minion

COPY conf/run-supervisor.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/run-supervisor.sh
CMD ["/usr/local/bin/run-supervisor.sh"]
