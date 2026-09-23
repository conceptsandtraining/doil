#!/bin/bash

# set vars
HOSTNAME=${1}

# remove old configuration if present
if [ -f "/etc/dovecot/conf.d/${HOSTNAME}.conf" ]
then
  rm "/etc/dovecot/conf.d/${HOSTNAME}.conf"
fi

# copy template
cp "/root/service-config.tpl" "/etc/dovecot/conf.d/${HOSTNAME}.conf"
sed -i "s/%DOMAIN%/${HOSTNAME}/g" "/etc/dovecot/conf.d/${HOSTNAME}.conf"

# remove old configuration if present
if [ -f "/etc/sieve/sieve.d/${HOSTNAME}.sieve" ]
then
  rm "/etc/sieve/sieve.d/${HOSTNAME}.sieve"
fi

# copy template
cp "/root/service-config-sieve.tpl" "/etc/sieve/sieve.d/${HOSTNAME}.sieve"
sed -i "s/%DOMAIN%/${HOSTNAME}/g" "/etc/sieve/sieve.d/${HOSTNAME}.sieve"

sievec "/etc/sieve/sieve.d/${HOSTNAME}.sieve"

# reload configuration
service dovecot restart