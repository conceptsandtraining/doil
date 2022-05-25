FROM debian:stable

# base
RUN apt-get update
RUN apt-get install -y supervisor salt-minion
RUN apt-get install -y vim less virt-what net-tools procps git debconf-utils

COPY conf/run-supervisor.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/run-supervisor.sh
CMD ["/usr/local/bin/run-supervisor.sh"]
