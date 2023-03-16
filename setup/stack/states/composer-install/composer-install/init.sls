ilias-composer-install:
  cmd.run:
    - name: composer install
    - cwd: /var/www/html
    - runas: root