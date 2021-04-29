FROM debian:stable

RUN apt-get update
RUN apt-get install -y vim less virt-what net-tools procps salt-master

ENTRYPOINT ["salt-master", "-l", "debug"]