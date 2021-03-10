/var/www/html:
  file.directory:
    - user: www-data
    - group: www-data
    - mode: 755
    - makedirs: True

/var/ilias/data:
  file.directory:
    - user: www-data
    - group: www-data
    - mode: 755
    - makedirs: True

/var/ilias/logs:
  file.directory:
    - user: www-data
    - group: www-data
    - mode: 755
    - makedirs: True

ilias_git_config:
  git.config_set:
    - name: core.fileMode
    - value: false
    - repo: /var/www/html

#/var/ilias/data/ilias-config.json:
#  file.managed:
#    - source: salt://ilias/ilias-config.json
#    - template: jinja
#    - context:
#      client_id: ilias
#      master_password: ilias
#      server_timezone: 'Europe/Berlin'
#      db_user: ilias
#      db_name: ilias
#      db_type: 'innodb'
#      db_create: 'true'
#      db_pass: ilias
#      data_dir: /var/ilias/data
#      contact_firstname: 'CaT'
#      contact_lastname: 'Concepts and Training GmbH'
#      contact_mail: 'noreply@concepts-and-training.de'
#      language: 'de'
#      log_dir: /var/ilias/logs
#      http_path: http://ilias.local
#    - user: www-data
#    - group: www-data
#    - mode: 640

get-composer:
  cmd.run:
    - name: php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    - unless: test -f /usr/local/bin/composer
    - cwd: /root/

install-composer:
  cmd.wait:
    - name: php composer-setup.php --version=1.10.17
    - cwd: /root/
    - watch:
      - cmd: get-composer

move-composer:
  cmd.wait:
    - name: mv /root/composer.phar /usr/local/bin/composer
    - cwd: /root/
    - watch:
      - cmd: install-composer

ilias-composer-install:
  cmd.wait:
    - name: 'cd /var/www/html && composer install'
    - cwd: /var/www/html
    - watch:
      - cmd: move-composer

#ilias-setup:
#  cmd.wait:
#    - name: "php /var/www/html/setup/setup.php install -y /var/ilias/data/ilias-config.json"
#    - watch: 
#      - cmd: ilias-composer-install

ilias-permissions:
  cmd.wait:
    - name: "chown -R www-data:www-data /var/www/ && chown -R www-data:www-data /var/ilias && service apache2 restart"
    - watch:
      - cmd: ilias-composer-install
