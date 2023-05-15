FROM debian:11

RUN apt-get update && apt-get install -y salt-minion supervisor

RUN apt-get update && apt-get install -y cron default-jre apache2 mc vim nano less zip unzip git tree wget ftp curl imagemagick ghostscript npm libapache2-mod-php7.4 php7.4-curl php7.4-gd php7.4-json php7.4-mysql php7.4-readline php7.4-xsl php7.4-cli php7.4-zip php7.4-mbstring php7.4-soap php7.4-bcmath php7.4-imap apt-utils mariadb-server python3-mysqldb

RUN echo "#!/bin/bash" > /usr/local/bin/run-supervisor.sh && echo "/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf" >> /usr/local/bin/run-supervisor.sh
RUN chmod +x /usr/local/bin/run-supervisor.sh
ENTRYPOINT ["/usr/local/bin/run-supervisor.sh"]
