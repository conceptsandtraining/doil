FROM debian:stable

RUN apt-get update && apt-get install -y vim nano less virt-what net-tools procps salt-master

ENTRYPOINT ["salt-master", "-l", "debug"]