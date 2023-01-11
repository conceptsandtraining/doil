FROM debian:stable

RUN apt-get update
RUN apt-get install -y salt-minion supervisor

RUN apt-get install -y cron default-jre apache2 mc vim nano less zip unzip git tree wget ftp curl imagemagick ghostscript npm libapache2-mod-php7.4 php7.4-curl php7.4-gd php7.4-json php7.4-mysql php7.4-readline php7.4-xsl php7.4-cli php7.4-zip php7.4-mbstring php7.4-soap php7.4-bcmath php7.4-imap apt-utils

RUN usermod -u %USER_ID% www-data
RUN groupmod -g %GROUP_ID% www-data

COPY conf/run-supervisor.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/run-supervisor.sh
ENTRYPOINT ["/usr/local/bin/run-supervisor.sh"]
