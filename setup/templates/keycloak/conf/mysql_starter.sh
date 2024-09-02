#!/bin/bash

chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql
/usr/bin/pidproxy /var/run/mysqld/mysqld.pid /usr/bin/mysqld_safe --datadir=/var/lib/mysql --pid-file=/var/run/mysqld/mysqld.pid