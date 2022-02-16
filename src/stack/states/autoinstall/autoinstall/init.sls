{% set mysql_password = salt['grains.get']('mysql_password', 'ilias') %}
{% set doil_domain = salt['grains.get']('doil_domain', 'http://ilias.local') %}
{% set doil_host_system = salt['grains.get']('doil_host_system', 'linux') %}

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
      db_pass: {{ mysql_password }}
      data_dir: /var/ilias/data
      contact_firstname: 'CaT'
      contact_lastname: 'Concepts and Training GmbH'
      contact_mail: 'noreply@concepts-and-training.de'
      language: 'de'
      log_dir: /var/ilias/logs
      http_path: {{ doil_domain }}

ilias-setup:
  cmd.run:
    - name: php /var/www/html/setup/setup.php install -y /var/ilias/data/ilias-config.json

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