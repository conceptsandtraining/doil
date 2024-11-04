FROM debian:12

# base
RUN apt-get update && apt-get install -y supervisor
RUN apt-get update && apt-get install -y vim nano curl less virt-what net-tools procps git debconf-utils python3-dev default-libmysqlclient-dev build-essential pkg-config

RUN curl -fsSL https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public | tee /etc/apt/keyrings/salt-archive-keyring.pgp
RUN curl -fsSL https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources | tee /etc/apt/sources.list.d/salt.sources
RUN apt-get update && apt-get install -y salt-minion

RUN /opt/saltstack/salt/bin/python3 -m pip install --upgrade pip
RUN /opt/saltstack/salt/bin/python3 -m pip install mysql

RUN apt-get update && apt-get remove -y python3-dev default-libmysqlclient-dev build-essential pkg-config

COPY conf/run-supervisor.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/run-supervisor.sh
CMD ["/usr/local/bin/run-supervisor.sh"]
