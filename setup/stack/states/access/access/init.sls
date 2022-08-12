{% set doil_host_system = salt['grains.get']('doil_host_system', 'linux') %}

packages_check:
  pkg.installed:
    - pkgs:
      - ftp
      - curl
      - imagemagick
      - ghostscript
      - npm

/var/www/html/:
  file.directory:
    - user: www-data
    - group: www-data
    - recurse:
      - user
      - group

/var/ilias/:
  file.directory:
    - user: www-data
    - group: www-data
    - recurse:
      - user
      - group

{%- if salt['file.directory_exists' ]('/var/www/html/CI/tools') %}
/var/www/html/CI/tools/compile-skins.sh:
  file.managed:
    - mode: 775
{%- endif %}