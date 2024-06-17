{% set ilias_version = salt['grains.get']('ilias_version', '8.0') %}

/var/www/html/.update_hook.php:
  file.managed:
    - source: salt://ilias-update-hook/update_hook.php.j2
    - template: jinja
    - context:
      ilias_version: {{ ilias_version }}