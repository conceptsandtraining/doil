# Fetch Ubuntu
FROM ubuntu:latest

# Update apt
RUN apt-get update
RUN apt-get upgrade -y

# Debian configs
COPY conf/debconf.selections /tmp/
RUN debconf-set-selections /tmp/debconf.selections

# Set ENV
ENV ALLOW_OVERRIDE All
ENV DATE_TIMEZONE UTC
ENV TERM dumb

# Prevent interactions for TZ configuration
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install standard packages
RUN apt-get install -y zip unzip git nodejs composer nano tree vim curl ftp imagemagick ffmpeg phantomjs vim

# Install php 7.3
RUN apt-get update
RUN apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:ondrej/php
RUN apt-get update
RUN apt-get install -y php7.3 php7.3-bz2 php7.3-cgi php7.3-cli php7.3-common php7.3-curl php7.3-dev php7.3-enchant php7.3-fpm php7.3-gd php7.3-gmp php7.3-imap php7.3-interbase php7.3-intl php7.3-json php7.3-ldap php7.3-mbstring php7.3-mysql php7.3-odbc php7.3-opcache php7.3-pgsql php7.3-phpdbg php7.3-pspell php7.3-readline php7.3-recode php7.3-snmp php7.3-sqlite3 php7.3-sybase php7.3-tidy php7.3-xmlrpc php7.3-xsl php7.3-zip

# Install apache2
RUN apt-get install -y apache2 libapache2-mod-php7.3

# Install MySQL
#RUN apt-get install -y mariadb-common mariadb-server mariadb-client

# Install Mailserver
RUN apt-get install -y postfix

# Install Bower Packages
RUN apt-get install -y npm
RUN npm install -g grunt-cli less

# Relink everything
RUN a2enmod rewrite

# Set the volumes
VOLUME /var/www/html
VOLUME /var/log/httpd
VOLUME /var/lib/mysql
VOLUME /var/log/mysql
VOLUME /etc/apache2

# Make folders accessable
RUN chown -R www-data:www-data /var/www

# Run server
COPY shell/run-lamp.sh /var/www/
RUN chmod +x /var/www/run-lamp.sh
CMD ["/var/www/run-lamp.sh"]

#su - www-data -s /bin/bash -c 'cd /var/www/html/ilias/setup && php setup.php install minimal-config.json'
