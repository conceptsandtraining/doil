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
      - php7.4-xmlrpc

php7.0:
  pkg.removed:
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

php7.1:
  pkg.removed:
    - pkgs:
      - libapache2-mod-php7.1
      - php7.1-curl
      - php7.1-gd
      - php7.1-json
      - php7.1-mysql
      - php7.1-readline
      - php7.1-xsl
      - php7.1-cli
      - php7.1-zip
      - php7.1-mbstring
      - php7.1-soap
      - php7.1-bcmath
      - php7.1-imap

php7.2:
  pkg.removed:
    - pkgs:
      - libapache2-mod-php7.2
      - php7.2-curl
      - php7.2-gd
      - php7.2-json
      - php7.2-mysql
      - php7.2-readline
      - php7.2-xsl
      - php7.2-cli
      - php7.2-zip
      - php7.2-mbstring
      - php7.2-soap
      - php7.2-bcmath
      - php7.2-imap

php7.3:
  pkg.removed:
    - pkgs:
      - libapache2-mod-php7.3
      - php7.3-curl
      - php7.3-gd
      - php7.3-json
      - php7.3-mysql
      - php7.3-readline
      - php7.3-xsl
      - php7.3-cli
      - php7.3-zip
      - php7.3-mbstring
      - php7.3-soap
      - php7.3-bcmath
      - php7.3-imap

php8.0:
  pkg.removed:
    - pkgs:
      - libapache2-mod-php8.0
      - php8.0-mysql
      - php8.0-readline
      - php8.0-xsl
      - php8.0-cli
      - php8.0-soap
      - php8.0-bcmath
      - php8.0-imap

ini_filesize_apache2:
  cmd.run:
    - name: sed -i "/upload_max_filesize*/c upload_max_filesize = 4096M" /etc/php/7.4/apache2/php.ini

ini_filesize_cli:
  cmd.run:
    - name: sed -i "/upload_max_filesize*/c upload_max_filesize = 4096M" /etc/php/7.4/cli/php.ini

ini_postmax_apache2:
  cmd.run:
    - name: sed -i "/post_max_size*/c post_max_size = 4096M" /etc/php/7.4/apache2/php.ini

ini_postmax_cli:
  cmd.run:
    - name: sed -i "/post_max_size*/c post_max_size = 4096M" /etc/php/7.4/cli/php.ini

a2_disable_php73:
  module.run:
    - name: apache.a2dismod
    - mod: php7.3

a2_enable_php:
  module.run:
    - name: apache.a2enmod
    - mod: php7.4
