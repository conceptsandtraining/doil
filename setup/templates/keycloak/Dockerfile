FROM debian:12

RUN apt-get update && apt-get install -y supervisor
RUN apt-get update && apt-get install -y vim jq nano less virt-what net-tools procps curl unzip mariadb-server python3-dev default-libmysqlclient-dev build-essential pkg-config

RUN curl -LO https://download.java.net/java/GA/jdk21/fd2272bbf8e04c3dbaee13770090416c/35/GPL/openjdk-21_linux-x64_bin.tar.gz
RUN echo "$(curl -s https://download.java.net/java/GA/jdk21/fd2272bbf8e04c3dbaee13770090416c/35/GPL/openjdk-21_linux-x64_bin.tar.gz.sha256) openjdk-21_linux-x64_bin.tar.gz" | sha256sum -c
RUN tar xzf openjdk-21_linux-x64_bin.tar.gz
RUN rm openjdk-21_linux-x64_bin.tar.gz
ENV PATH="$PATH:/jdk-21/bin"
ENV JAVA_HOME="/jdk-21"

RUN curl -fsSL -o keycloak-25.0.5.zip https://github.com/keycloak/keycloak/releases/download/25.0.5/keycloak-25.0.5.zip
RUN echo "$(curl -fsSL https://github.com/keycloak/keycloak/releases/download/25.0.5/keycloak-25.0.5.zip.sha1) keycloak-25.0.5.zip" | sha1sum -c
RUN unzip keycloak-25.0.5.zip
RUN mv keycloak-25.0.5 /opt/keycloak
RUN rm keycloak-25.0.5.zip

RUN curl -fsSL https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public | tee /etc/apt/keyrings/salt-archive-keyring.pgp
RUN curl -fsSL https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources | tee /etc/apt/sources.list.d/salt.sources
RUN apt-get update && apt-get install -y salt-minion

RUN /opt/saltstack/salt/bin/python3 -m pip install --upgrade pip
RUN /opt/saltstack/salt/bin/python3 -m pip install mysql
RUN apt-get update && apt-get remove -y python3-dev default-libmysqlclient-dev build-essential pkg-config

COPY conf/keycloak-startup.conf /etc/supervisor/conf.d
COPY conf/mysql.conf /etc/supervisor/conf.d
COPY conf/salt-minion.conf /etc/supervisor/conf.d
COPY conf/mysql_starter.sh /root/
COPY conf/startup.conf /etc/supervisor/conf.d
COPY conf/minion.cnf /etc/salt/minion
COPY conf/salt-startup.sh /root
COPY conf/init.sql /root

RUN chmod +x /root/mysql_starter.sh
RUN chmod +x /root/salt-startup.sh

COPY conf/run-supervisor.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/run-supervisor.sh

RUN echo "keycloak:x:10001" >> /etc/group && \
    echo "keycloak:x:10001:10001:keycloak user:/opt/keycloak:/sbin/nologin" >> /etc/passwd
RUN chown -cR keycloak:keycloak /opt/keycloak

CMD ["/usr/local/bin/run-supervisor.sh"]