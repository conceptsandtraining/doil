{% set doil_host_system = salt['grains.get']('doil_host_system', 'linux') %}

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

{%- if salt['file.file_exists' ]('/var/www/html/CI/tools/compile-skins.sh') %}
/var/www/html/CI/tools/compile-skins.sh:
  file.managed:
    - mode: 775
{%- endif %}