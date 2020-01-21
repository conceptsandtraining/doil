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

# Install php %TPL_PHPVERSION%
RUN apt-get update
RUN apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:ondrej/php
RUN apt-get update
RUN apt-get install -y php%TPL_PHPVERSION% php%TPL_PHPVERSION%-bz2 php%TPL_PHPVERSION%-cgi php%TPL_PHPVERSION%-cli php%TPL_PHPVERSION%-common php%TPL_PHPVERSION%-curl php%TPL_PHPVERSION%-dev php%TPL_PHPVERSION%-enchant php%TPL_PHPVERSION%-fpm php%TPL_PHPVERSION%-gd php%TPL_PHPVERSION%-gmp php%TPL_PHPVERSION%-imap php%TPL_PHPVERSION%-interbase php%TPL_PHPVERSION%-intl php%TPL_PHPVERSION%-json php%TPL_PHPVERSION%-ldap php%TPL_PHPVERSION%-mbstring php%TPL_PHPVERSION%-mysql php%TPL_PHPVERSION%-odbc php%TPL_PHPVERSION%-opcache php%TPL_PHPVERSION%-pgsql php%TPL_PHPVERSION%-phpdbg php%TPL_PHPVERSION%-pspell php%TPL_PHPVERSION%-readline php%TPL_PHPVERSION%-recode php%TPL_PHPVERSION%-snmp php%TPL_PHPVERSION%-sqlite3 php%TPL_PHPVERSION%-sybase php%TPL_PHPVERSION%-tidy php%TPL_PHPVERSION%-xmlrpc php%TPL_PHPVERSION%-xsl php%TPL_PHPVERSION%-zip php%TPL_PHPVERSION%-soap

# Install apache2
RUN apt-get install -y apache2 libapache2-mod-php%TPL_PHPVERSION%

# Install Mailserver
RUN apt-get install -y postfix

# Install Bower Packages
RUN apt-get install -y npm
RUN npm install -g grunt-cli less

# Relink everything
RUN a2enmod rewrite

# Set the volumes
VOLUME /var/www/html
VOLUME /var/ilias
VOLUME /var/log/httpd
VOLUME /var/lib/mysql
VOLUME /var/log/mysql
VOLUME /etc/apache2

# Run composer installation
COPY conf/composer-install.sh /var/www/
RUN chmod +x /var/www/composer-install.sh
CMD ["/var/www/composer-install.sh"]

# Make folders accessable
RUN chown -R www-data:www-data /var/www
RUN chown -R www-data:www-data /var/ilias

# Run server
COPY conf/run-lamp.sh /var/www/
RUN chmod +x /var/www/run-lamp.sh
CMD ["/var/www/run-lamp.sh"]
