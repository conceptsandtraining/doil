#!/bin/bash

# we need to remove the php cli versions in order to get a positive
# composer install result
apt-get remove -y php7.1-cli php7.2-cli php7.0-cli php7.4-cli php8.0-cli