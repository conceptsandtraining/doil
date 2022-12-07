#!/bin/bash

/usr/sbin/postfix -c /etc/postfix start &

finish() {
        kill -9 "$(cat /var/spool/postfix/pid/master.pid)"
        exit
}

trap finish SIGINT

while :; do
        sleep 5
done
