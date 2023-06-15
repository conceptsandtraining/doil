FROM debian:11

RUN apt-get update && apt-get install -y vim curl zip unzip git php7.4-cli php7.4-zip php7.4-dom php7.4-mbstring php7.4-json docker.io docker-compose

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

RUN mkdir /srv/php
RUN mv /etc/php/7.4/cli/php.ini /srv/php
RUN mv /etc/php/7.4/mods-available /srv/php
