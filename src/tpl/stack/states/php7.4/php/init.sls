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

php7.4:
  pkg.installed:
    - refresh: true
    - pkgs:
      - libapache2-mod-php7.4
      - php7.4-curl
      - php7.4-gd
      - php7.4-json
      - php7.4-mysql
      - php7.4-readline
      - php7.4-xsl
      - php7.4-cli
      - php7.4-zip
      - php7.4-mbstring
      - php7.4-soap
      - php7.4-bcmath
      - php7.4-imap

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

a2_enable_php:
  module.run:
    - name: apache.a2enmod
    - mod: php7.4
