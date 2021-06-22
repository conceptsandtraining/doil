apt_https:
  pkg.installed:
    - name: software-properties-common

php_repo_list:
  cmd.run:
    - name: echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
    - unless: test -f /etc/apt/sources.list.d/php.list

php_repo_key:
  cmd.run:
    - name: wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
    - unless: test -f /etc/apt/trusted.gpg.d/php.gpg

php7.0:
  pkg.installed:
    - refresh: true
    - pkgs:
      - libapache2-mod-php7.0
      - php7.0-curl
      - php7.0-gd
      - php7.0-json
      - php7.0-mysql
      - php7.0-readline
      - php7.0-xsl
      - php7.0-cli
      - php7.0-zip
      - php7.0-mbstring
      - php7.0-xml
      - php7.0-soap
      - php7.0-bcmath
      - php7.0-imap

/root/cleanup.sh:
  file.managed:
    - source: salt://php/cleanup.sh
    - user: root
    - group: root
    - mode: 740

cleanup:
  cmd.run:
    - cwd: /root/
    - name: ./cleanup.sh

a2_disable_php73:
  module.run:
    - name: apache.a2dismod
    - mod: php7.3

a2_disable_php74:
  module.run:
    - name: apache.a2dismod
    - mod: php7.4

a2_enable_php:
  module.run:
    - name: apache.a2enmod
    - mod: php7.0
