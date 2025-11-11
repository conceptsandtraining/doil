{% set ilias_version = salt['grains.get']('ilias_version', '8.0') %}

/var/www/html/.update_hook.php:
  file.managed:
    - source: salt://ilias-update-hook/update_hook.php.j2
    - user: www-data
    - group: www-data
    - template: jinja
    - context:
      ilias_version: {{ ilias_version }}

/var/log/doil/instance-update.log:
  file.managed:
    - user: www-data
    - group: www-data
    - mode: 600
