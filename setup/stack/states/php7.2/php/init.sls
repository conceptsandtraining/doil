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

php7.2:
  pkg.installed:
    - refresh: True
    - skip_verify: True
    - pkgs:
      - libapache2-mod-php7.2
      - php7.2-json
      - php7.2-apcu
      - php7.2-bcmath
      - php7.2-cli
      - php7.2-curl
      - php7.2-gd
      - php7.2-imap
      - php7.2-mbstring
      - php7.2-mysql
      - php7.2-opcache
      - php7.2-readline
      - php7.2-soap
      - php7.2-xml
      - php7.2-xmlrpc
      - php7.2-xsl
      - php7.2-zip

{% for version in ['7.0','7.1','7.3','7.4','8.0','8.1','8.2','8.3','8.4'] %}
php{{ version }}:
  pkg.purged:
    - refresh: True
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
          - php{{ version }}-imagick
{% endfor %}

ini_filesize_apache2:
  cmd.run:
    - name: sed -i "/upload_max_filesize*/c upload_max_filesize = 4096M" /etc/php/7.2/apache2/php.ini

ini_filesize_cli:
  cmd.run:
    - name: sed -i "/upload_max_filesize*/c upload_max_filesize = 4096M" /etc/php/7.2/cli/php.ini

ini_postmax_apache2:
  cmd.run:
    - name: sed -i "/post_max_size*/c post_max_size = 4096M" /etc/php/7.2/apache2/php.ini

ini_postmax_cli:
  cmd.run:
    - name: sed -i "/post_max_size*/c post_max_size = 4096M" /etc/php/7.2/cli/php.ini

ini_max_execution_time_apache2:
  cmd.run:
    - name: sed -i "/max_execution_time*/c max_execution_time = 3600" /etc/php/7.2/apache2/php.ini

ini_max_execution_time_cli:
  cmd.run:
    - name: sed -i "/max_execution_time*/c max_execution_time = 3600" /etc/php/7.2/cli/php.ini

a2_enable_php:
  module.run:
    - name: apache.a2enmod
    - mod: php7.2

update_alternatives_php:
  cmd.run:
    - name: update-alternatives --set php /usr/bin/php7.2 &>/dev/null

apache2_supervisor_signal:
  cmd.run:
    - name: supervisorctl restart apache2
