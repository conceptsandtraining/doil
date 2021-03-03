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
    - name: 'cd /var/www/html/libs/composer && composer install'
    - cwd: /var/www/html/libs/composer
    - watch:
      - cmd: move-composer

ilias-permissions:
  cmd.wait:
    - name: "chown -R www-data:www-data /var/www/ && chown -R www-data:www-data /var/ilias && service apache2 restart"
    - watch:
      - cmd: ilias-composer-install
