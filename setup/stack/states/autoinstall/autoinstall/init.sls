{% set mysql_password = salt['grains.get']('mpass', 'ilias') %}
{% set doil_domain = salt['grains.get']('doil_domain', 'http://ilias.local') %}
{% set doil_allowed_hosts = salt['grains.get']('doil_allowed_hosts', [""]) %}
{% set doil_host_system = salt['grains.get']('doil_host_system', 'linux') %}
{% set ilias_version = salt['grains.get']('ilias_version', '9') %}

/var/ilias/data/ilias-config.json:
  file.managed:
    - source: salt://autoinstall/ilias-config.json
    - template: jinja
    - context:
      client_id: ilias
      master_password: ilias
      server_timezone: 'Europe/Berlin'
      db_user: ilias
      db_name: ilias
      db_type: 'innodb'
      db_create: 'true'
      db_pass: '{{ mysql_password }}'
      data_dir: /var/ilias/data
      contact_firstname: 'CaT'
      contact_lastname: 'Concepts and Training GmbH'
      contact_mail: 'noreply@concepts-and-training.de'
      language: 'de'
      log_dir: /var/ilias/logs
      http_path: '{{ doil_domain }}'
      allowed_hosts: {{ doil_allowed_hosts }}

{% if ilias_version | int < 10 %}
ilias_setup_lt_10:
  cmd.run:
    - name: cd /var/www/html && php setup/setup.php install -y /var/ilias/data/ilias-config.json
{% else %}
ilias_setup_ge_10:
  cmd.run:
    - name: cd /var/www/html && php cli/setup.php install -y /var/ilias/data/ilias-config.json
{% endif %}

{% if salt['grains.get'] == 'linux' %}
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
{% endif %}