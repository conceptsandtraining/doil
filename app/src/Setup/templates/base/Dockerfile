FROM debian:13

RUN apt-get update && apt-get install -y supervisor wget

RUN mkdir -p /etc/apt/keyrings
RUN echo "deb https://packages.sury.org/php/ trixie main" > /etc/apt/sources.list.d/php.list
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg

RUN apt-get update && apt-get install -y \
   default-jdk-headless \
   cron \
   apache2 \
   mc \
   vim \
   nano \
   less \
   zip \
   unzip \
   git \
   tree \
   ftp \
   curl \
   imagemagick \
   ghostscript \
   npm \
   libapache2-mod-php8.4 \
   php8.4-curl \
   php8.4-gd \
   php-json \
   php8.4-mysql \
   php8.4-readline \
   php8.4-xsl \
   php8.4-cli \
   php8.4-zip \
   php8.4-mbstring \
   php8.4-soap \
   php8.4-bcmath \
   php8.4-imap \
   apt-utils \
   mariadb-server \
   python3-mysqldb \
   python3-dev \
   default-libmysqlclient-dev \
   build-essential \
   pkg-config

RUN wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.bookworm_amd64.deb
RUN apt install -y ./wkhtmltox_0.12.6.1-3.bookworm_amd64.deb

RUN curl -fsSL https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public | tee /etc/apt/keyrings/salt-archive-keyring.pgp
RUN curl -fsSL https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources | tee /etc/apt/sources.list.d/salt.sources
RUN apt-get update && apt-get install -y salt-minion

RUN /opt/saltstack/salt/bin/python3 -m pip install --upgrade pip
RUN /opt/saltstack/salt/bin/python3 -m pip install mysql

RUN apt-get update && apt-get remove -y python3-dev default-libmysqlclient-dev build-essential pkg-config

RUN echo "#!/bin/bash" > /usr/local/bin/run-supervisor.sh && echo "/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf" >> /usr/local/bin/run-supervisor.sh
RUN chmod +x /usr/local/bin/run-supervisor.sh

ENTRYPOINT ["/usr/local/bin/run-supervisor.sh"]
