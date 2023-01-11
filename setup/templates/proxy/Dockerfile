FROM debian:stable

RUN apt-get update
RUN apt-get install -y supervisor salt-minion
RUN apt-get install -y vim nano less virt-what net-tools procps

EXPOSE 80 443

COPY conf/run-supervisor.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/run-supervisor.sh
CMD ["/usr/local/bin/run-supervisor.sh"]
