# Fetch Ubuntu
FROM ubuntu:20.04

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

# Install php 7.2
RUN apt-get update
RUN apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:ondrej/php
RUN apt-get update
RUN apt-get install -y php7.2 php7.2-bz2 php7.2-cgi php7.2-cli php7.2-common php7.2-curl php7.2-dev php7.2-enchant php7.2-fpm php7.2-gd php7.2-gmp php7.2-imap php7.2-interbase php7.2-intl php7.2-json php7.2-ldap php7.2-mbstring php7.2-mysql php7.2-odbc php7.2-opcache php7.2-pgsql php7.2-phpdbg php7.2-pspell php7.2-readline php7.2-recode php7.2-snmp php7.2-sqlite3 php7.2-sybase php7.2-tidy php7.2-xmlrpc php7.2-xsl php7.2-zip php7.2-soap php7.2-bcmath

# Install apache2
RUN apt-get install -y apache2 libapache2-mod-php7.2

# Install Mailserver
RUN apt-get install -y postfix

# Install Bower Packages
RUN apt-get install -y npm
RUN npm install -g grunt-cli less

# Remove php7.4
RUN apt-get remove -y php7.4-cli

# Relink everything
RUN a2enmod rewrite

# Set the volumes
VOLUME /var/www/html
VOLUME /var/ilias
VOLUME /var/log/httpd
VOLUME /var/lib/mysql
VOLUME /var/log/mysql
VOLUME /etc/apache2

# Copy composer script
COPY conf/composer-install.sh /var/www/
RUN chmod +x /var/www/composer-install.sh

# Make folders accessable
RUN chown -R www-data:www-data /var/www
RUN chown -R www-data:www-data /var/ilias

# Run server
COPY conf/run-lamp.sh /var/www/
RUN chmod +x /var/www/run-lamp.sh
CMD ["/var/www/run-lamp.sh"]
