FROM debian:12

RUN apt-get update && apt-get install -y supervisor
RUN apt-get update && apt-get install -y cron default-jre apache2 mc vim nano less zip unzip git tree wget ftp curl wkhtmltopdf imagemagick ghostscript npm libapache2-mod-php8.2 php8.2-curl php8.2-gd php-json php8.2-mysql php8.2-readline php8.2-xsl php8.2-cli php8.2-zip php8.2-mbstring php8.2-soap php8.2-bcmath php8.2-imap apt-utils mariadb-server python3-mysqldb python3-dev default-libmysqlclient-dev build-essential pkg-config

RUN curl -fsSL -o /etc/apt/keyrings/salt-archive-keyring-2023.gpg https://repo.saltproject.io/salt/py3/debian/12/amd64/SALT-PROJECT-GPG-PUBKEY-2023.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/salt-archive-keyring-2023.gpg arch=amd64] https://repo.saltproject.io/salt/py3/debian/12/amd64/latest bookworm main" | tee /etc/apt/sources.list.d/salt.list
RUN apt-get update && apt-get install -y salt-minion

RUN /opt/saltstack/salt/bin/python3 -m pip install --upgrade pip
RUN /opt/saltstack/salt/bin/python3 -m pip install mysql

RUN apt-get update && apt-get remove -y python3-dev default-libmysqlclient-dev build-essential pkg-config

RUN echo "#!/bin/bash" > /usr/local/bin/run-supervisor.sh && echo "/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf" >> /usr/local/bin/run-supervisor.sh
RUN chmod +x /usr/local/bin/run-supervisor.sh

ENTRYPOINT ["/usr/local/bin/run-supervisor.sh"]
