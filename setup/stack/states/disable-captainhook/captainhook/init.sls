{% set ilias_version = salt['grains.get']('ilias_version', '9') %}

{% if ilias_version | int < 10 %}
disable_captainhook_lt_10:
  cmd.run:
    - name: libs/composer/vendor/bin/captainhook uninstall -q
    - cwd: /var/www/html
{% else %}
disable_captainhook_ge_10:
  cmd.run:
    - name: vendor/composer/vendor/bin/captainhook uninstall -q
    - cwd: /var/www/html
{% endif %}
