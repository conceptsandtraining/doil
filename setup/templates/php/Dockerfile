FROM debian:11

RUN apt-get update && apt-get install -y vim curl zip unzip git php7.4-cli php7.4-zip php7.4-dom php7.4-mbstring php7.4-json docker.io docker-compose

RUN EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"
RUN if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then >&2 echo 'ERROR: Invalid installer checksum'; exit 1; fi
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

RUN mkdir /srv/php
RUN mv /etc/php/7.4/cli/php.ini /srv/php
RUN mv /etc/php/7.4/mods-available /srv/php
