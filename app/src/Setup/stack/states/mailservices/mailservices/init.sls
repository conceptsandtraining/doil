# salt 'doil.mail' state.highstate saltenv=mailservices
{% set cpu = salt['grains.get']('num_cpus', '4') %}
{% set ram = salt['grains.get']('mem_total', '4096') %}
{% set doil_host_system = salt['grains.get']('doil_host_system', 'linux') %}

get_wget:
  pkg.installed:
    - pkgs:
        - wget

php_repo_list:
  cmd.run:
    - name: echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
    - unless: test -f /etc/apt/sources.list.d/php.list

php_repo_key:
  cmd.run:
    - name: wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
    - unless: test -f /etc/apt/trusted.gpg.d/php.gpg

mailservice_packages:
  pkg.installed:
    - refresh: True
    - pkgs:
      - apache2
      - mariadb-server
      - python3-mysqldb
      - postfix
      - roundcube
      - roundcube-plugins
      - libapache2-mod-php8.4
      - php8.4-curl
      - php8.4-gd
      - php-json
      - php8.4-mysql
      - php8.4-readline
      - php8.4-xsl
      - php8.4-cli
      - php8.4-zip
      - php8.4-mbstring
      - php8.4-soap
      - php8.4-bcmath
      - php8.4-imap
      - php8.4-xmlrpc

stop_dovecot:
  cmd.run:
    - name: /etc/init.d/dovecot stop

/var/mail/www-data:
  file.directory:
    - user: www-data
    - group: mail
    - recurse:
      - user
      - group

/etc/mysql/mariadb.conf.d/50-server.cnf:
  file:
    - managed
    - source: salt://mailservices/mysql-my.cnf
    - template: jinja
    - context:
      cpu: {{ cpu }}
      ram: {{ ram }}

/etc/mysql/:
  file.directory:
    - user: root
    - group: root
    - recurse:
      - user
      - group

/var/lib/mysql/:
  file.directory:
    - user: mysql
    - group: mysql
    - recurse:
      - user
      - group

/etc/sieve/:
  file.directory:
    - user: www-data
    - group: www-data
    - recurse:
      - user
      - group

/etc/sieve/sieve.d/:
  file.directory:
    - user: www-data
    - group: www-data
    - recurse:
      - user
      - group

a2_enable_php:
  module.run:
    - name: apache.a2enmod
    - mod: php8.4

/etc/mailname:
  file.managed:
    - source: salt://mailservices/mailname

/etc/postfix/main.cf:
  file.managed:
    - source: salt://mailservices/postfix-main.cf

/etc/postfix/canonical-redirect:
  file.managed:
    - source: salt://mailservices/postfix-canonical-redirect

postfix-postmap:
  cmd.run:
    - name: postmap /etc/postfix/canonical-redirect

/etc/dovecot/conf.d/10-mail.conf:
  file.managed:
    - source: salt://mailservices/dovecot-10-mail.conf

/etc/dovecot/conf.d/15-lda.conf:
  file.managed:
    - source: salt://mailservices/dovecot-15-lda.conf

/etc/dovecot/conf.d/90-sieve.conf:
  file.managed:
    - source: salt://mailservices/dovecot-90-sieve.conf

/etc/apache2/conf-enabled/roundcube.conf:
  file.managed:
    - source: salt://mailservices/roundcube.conf

/etc/roundcube/debian-db.php:
  file.managed:
    - source: salt://mailservices/roundcube-debian-db.php

/etc/supervisor/conf.d/apache2.conf:
  file.managed:
    - source: salt://mailservices/sv-apache.conf

/etc/supervisor/conf.d/mysql.conf:
  file.managed:
    - source: salt://mailservices/sv-mysql.conf

/etc/supervisor/conf.d/postfix.conf:
  file.managed:
    - source: salt://mailservices/sv-postfix.conf

/etc/supervisor/conf.d/dovecot.conf:
  file.managed:
    - source: salt://mailservices/sv-dovecot.conf

apache_supervisor_signal:
  supervisord.running:
    - name: apache2
    - watch:
      - file: /etc/supervisor/conf.d/apache2.conf

mysql_supervisor_signal:
  supervisord.running:
    - name: mysqld
    - watch:
      - file: /etc/supervisor/conf.d/mysql.conf

postfix_supervisor_signal:
  supervisord.running:
    - name: postfix
    - watch:
      - file: /etc/supervisor/conf.d/postfix.conf
      - file: /root/postfix_fg_starter.sh

dovecot_supervisor_signal:
  supervisord.running:
    - name: dovecot
    - watch:
      - file: /etc/supervisor/conf.d/dovecot.conf

mysql_adduser:
  mysql_user.present:
    - name: roundcube
    - host: 'localhost'
    - password: roundcube

mysql_grant:
  mysql_grants.present:
    - grant: all privileges
    - user: roundcube
    - database: '*.*'
    - grant_option: true

mysql_database:
  mysql_database.present:
    - name: roundcube

init-www-data:
  cmd.run:
    - name: touch /var/mail/www-data && mkdir -p /var/www/mail && chown -R www-data:mail /var/mail/www-data && chown -R www-data:mail /var/www/mail

www-data:
  user.present:
    - name: www-data
    - password: $6$xUv8xrV06vQ5DexD$PL.aUE6zesb9d6qBB6FnJtli6jIJ2Ud00JlnLcW0G4p2nwgwX7lryvFb1RiFEMIc22OwQ7f9LnplchpaUBRB51
    - groups:
      - dovecot
      - postfix
      - mail

install-roundcube:
  cmd.run:
    - name: mysql roundcube < /usr/share/roundcube/SQL/mysql.initial.sql

roundcube-plugins:
  cmd.run:
    - name: cp /usr/share/roundcube/plugins/managesieve/config.inc.php.dist /etc/roundcube/plugins/managesieve/config.inc.php

/etc/roundcube/config.inc.php:
  file.managed:
    - source: salt://mailservices/roundcube-config.inc.php

/var/www/:
  file.directory:
    - user: www-data
    - group: www-data
    - mode: 755
    - makedirs: True

/root/check-postbox-configuration.sh:
  file.managed:
    - source: salt://mailservices/check-postbox-configuration.sh
    - mode: 755

/root/delete-postbox-configuration.sh:
  file.managed:
    - source: salt://mailservices/delete-postbox-configuration.sh
    - mode: 755

/root/postfix_fg_starter.sh:
  file.managed:
    - source: salt://mailservices/postfix_fg_starter.sh
    - mode: 755

/root/service-config.tpl:
  file.managed:
    - source: salt://mailservices/service-config.tpl

/root/service-config-sieve.tpl:
  file.managed:
    - source: salt://mailservices/service-config-sieve.tpl
