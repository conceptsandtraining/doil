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

php7.3:
  pkg.installed:
    - pkgs:
      - libapache2-mod-php7.3
      - php-json
      - php7.3-apcu
      - php7.3-bcmath
      - php7.3-cli
      - php7.3-curl
      - php7.3-gd
      - php7.3-imap
      - php7.3-mbstring
      - php7.3-mysql
      - php7.3-opcache
      - php7.3-readline
      - php7.3-soap
      - php7.3-xml
      - php7.3-xmlrpc
      - php7.3-xsl
      - php7.3-zip

{% for version in ['7.1','7.2','7.4','8.0','8.1'] %}
php{{ version }}:
  pkg.purged:
    - refresh: true
    - pkgs:
          - libapache2-mod-php{{ version }}
          - php{{ version }}-apcu
          - php{{ version }}-bcmath
          - php{{ version }}-cli
          - php{{ version }}-common
          - php{{ version }}-curl
          - php{{ version }}-gd
          - php{{ version }}-imap
          - php{{ version }}-json
          - php{{ version }}-mbstring
          - php{{ version }}-mysql
          - php{{ version }}-opcache
          - php{{ version }}-readline
          - php{{ version }}-soap
          - php{{ version }}-xml
          - php{{ version }}-xmlrpc
          - php{{ version }}-xsl
          - php{{ version }}-zip
{% endfor %}

ini_filesize_apache2:
  cmd.run:
    - name: sed -i "/upload_max_filesize*/c upload_max_filesize = 4096M" /etc/php/7.3/apache2/php.ini

ini_filesize_cli:
  cmd.run:
    - name: sed -i "/upload_max_filesize*/c upload_max_filesize = 4096M" /etc/php/7.3/cli/php.ini

ini_postmax_apache2:
  cmd.run:
    - name: sed -i "/post_max_size*/c post_max_size = 4096M" /etc/php/7.3/apache2/php.ini

ini_postmax_cli:
  cmd.run:
    - name: sed -i "/post_max_size*/c post_max_size = 4096M" /etc/php/7.3/cli/php.ini

a2_enable_php:
  module.run:
    - name: apache.a2enmod
    - mod: php7.3

apache2_supervisor_signal:
  cmd.run:
    - name: supervisorctl restart apache2
