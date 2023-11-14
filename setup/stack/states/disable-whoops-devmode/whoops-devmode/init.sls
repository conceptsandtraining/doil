{% set ilias_version = salt['grains.get']('ilias_version', '9') %}
{% if ilias_version | int < 10 %}
{% set client_ini_path = '/var/www/html/data/ilias/client.ini.php' %}
{% else %}
{% set client_ini_path = '/var/www/html/public/data/ilias/client.ini.php' %}
{% endif %}

remove_use_whoops:
  file.line:
    - name: {{ client_ini_path }}
    - match: '^USE_WHOOPS'
    - mode: delete

remove_devmode:
  file.line:
    - name: {{ client_ini_path }}
    - match: '^DEVMODE'
    - mode: delete