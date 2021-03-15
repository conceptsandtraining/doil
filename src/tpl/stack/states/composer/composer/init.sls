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