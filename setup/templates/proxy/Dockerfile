FROM debian:12

RUN apt-get update && apt-get install -y supervisor
RUN apt-get update && apt-get install -y vim nano less virt-what net-tools procps curl

RUN mkdir -m 755 -p /etc/apt/keyrings
RUN curl -fsSL https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public | tee /etc/apt/keyrings/salt-archive-keyring.pgp
RUN curl -fsSL https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources | tee /etc/apt/sources.list.d/salt.sources
RUN echo "Package: salt-*\nPin: version 3006.22\nPin-Priority: 1001" >> /etc/apt/preferences.d/salt-pin-1001
RUN apt-get update && apt-get install -y salt-minion

EXPOSE 80 443

COPY conf/run-supervisor.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/run-supervisor.sh
CMD ["/usr/local/bin/run-supervisor.sh"]
