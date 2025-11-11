FROM debian:13

RUN apt-get update && apt-get install -y vim nano less virt-what net-tools procps curl

RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public | tee /etc/apt/keyrings/salt-archive-keyring.pgp
RUN curl -fsSL https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources | tee /etc/apt/sources.list.d/salt.sources
RUN apt-get update && apt-get install -y salt-master

ENTRYPOINT ["salt-master", "-l", "debug"]