### Standard dev packages
devtools_packages:
  pkg.installed:
    - pkgs:
      - composer
      - ftp
      - curl
      - imagemagick
      - ghostscript

### Implement Adminer
# adminer-4.8.0-mysql-en.php
/var/www/adminer/index.php:
  file.managed:
    - source: salt://devtools/adminer-4.8.0-mysql-en.php
    - mode: 755
    - user: www-data
    - group: www-data
    - makedirs: True