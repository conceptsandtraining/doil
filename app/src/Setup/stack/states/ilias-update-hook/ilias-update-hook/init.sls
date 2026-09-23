{% set ilias_version = salt['grains.get']('ilias_version', '8.0') %}
{% set essential = salt['file.directory_exists']('/var/www/html/components/Essential')%}
{% set target_dir = "CaT" %}
{% if essential %}
{% set target_dir = "Essential" %}
{% endif %}

{% if ilias_version | float < 10.0 %}
/var/www/html/.update_hook.php:
  file.managed:
    - source: salt://ilias-update-hook/update_hook_9.php
    - user: www-data
    - group: www-data
{% else %}
/var/www/html/components/{{ target_dir }}/DevEnvironment/resources:
  file.directory:
    - user: www-data
    - group: www-data
    - dir_mode: "0755"
    - makedirs: True

/var/www/html/components/{{ target_dir }}/DevEnvironment/resources/.update_hook.php:
  file.managed:
    - source: salt://ilias-update-hook/update_hook.php.j2
    - user: www-data
    - group: www-data
    - template: jinja
    - context:
        target: {{ target_dir }}

/var/www/html/components/{{ target_dir }}/DevEnvironment/DevEnvironment.php:
  file.managed:
    - source: salt://ilias-update-hook/DevEnvironment.php.j2
    - user: www-data
    - group: www-data
    - template: jinja
    - context:
        workspace: {{ target_dir }}
{% endif %}

/var/log/doil/instance-update.log:
  file.managed:
    - user: www-data
    - group: www-data
    - mode: 600

composer_run:
  cmd.run:
    - name: cd /var/www/html && composer du
