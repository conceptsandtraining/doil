{% set ilias_version = salt['grains.get']('ilias_version', '9') %}
{% if ilias_version | int < 9 %}
{% set skin_compiler = 'lessc' %}
{% else %}
{% set skin_compiler = 'sass' %}
{% endif %}

### Standard dev packages
devtools_packages:
  pkg.installed:
    - pkgs:
      - ftp
      - curl
      - imagemagick
      - ghostscript
      - npm

# Install lessc/sass
/root/install-{{ skin_compiler }}.sh:
  file.managed:
    - source: salt://devtools/install-{{ skin_compiler }}.sh
    - user: root
    - group: root
    - mode: 740

install-{{ skin_compiler }}:
  cmd.run:
    - cwd: /root/
    - name: ./install-{{ skin_compiler }}.sh

# Install githook
/var/www/html/.git/hooks/post-merge:
  file.managed:
    - source: salt://devtools/githook-post-merge

### Implement Adminer
# adminer-4.8.0-mysql-en.php
/var/www/adminer/index.php:
  file.managed:
    - source: salt://devtools/adminer-4.8.0-mysql-en.php
    - makedirs: True