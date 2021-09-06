### Standard dev packages
devtools_packages:
  pkg.installed:
    - pkgs:
      - ftp
      - curl
      - imagemagick
      - ghostscript
      - npm

# Install lessc
/root/install-lessc.sh:
  file.managed:
    - source: salt://devtools/install-lessc.sh
    - user: root
    - group: root
    - mode: 740

install-lessc:
  cmd.run:
    - cwd: /root/
    - name: ./install-lessc.sh

# Install githook
/var/www/html/.git/hooks/post-merge:
  file.managed:
    - source: salt://devtools/githook-post-merge
    - user: www-data
    - group: www-data
    - mode: 744

### Implement Adminer
# adminer-4.8.0-mysql-en.php
/var/www/adminer/index.php:
  file.managed:
    - source: salt://devtools/adminer-4.8.0-mysql-en.php
    - mode: 755
    - user: www-data
    - group: www-data
    - makedirs: True