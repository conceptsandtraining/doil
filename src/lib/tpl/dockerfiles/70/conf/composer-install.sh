#!/bin/bash

if [[ -f "/var/www/html/libs/composer/composer.json" ]];
then
  cd /var/www/html/libs/composer
  composer install
elif [[ -f "/var/www/html/composer.json" ]];
then
  cd /var/www/html
  composer install
fi
