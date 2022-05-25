#!/bin/bash

# set vars
HOSTNAME=${1}

# remove old configuration if present
if [ -f "/etc/dovecot/conf.d/${HOSTNAME}.conf" ]
then
  rm "/etc/dovecot/conf.d/${HOSTNAME}.conf"
fi

if [ -f "/etc/sieve/sieve.d/${HOSTNAME}.sieve" ]
then
  rm "/etc/sieve/sieve.d/${HOSTNAME}.sieve"
fi

if [ -f "/etc/sieve/sieve.d/${HOSTNAME}.svbin" ]
then
  rm "/etc/sieve/sieve.d/${HOSTNAME}.svbin"
fi

if [ -d "/var/mail/www-data/.${HOSTNAME}" ]
then
  rm -rf "/var/mail/www-data/.${HOSTNAME}"
fi

# reload configuration
service dovecot restart