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
      db_pass: ilias
      data_dir: /var/ilias/data
      contact_firstname: 'CaT'
      contact_lastname: 'Concepts and Training GmbH'
      contact_mail: 'noreply@concepts-and-training.de'
      language: 'de'
      log_dir: /var/ilias/logs
      http_path: http://ilias.local
    - user: www-data
    - group: www-data
    - mode: 640

/root/config-replace.sh:
  file.managed:
    - source: salt://autoinstall/config-replace.sh
    - user: root
    - group: root
    - mode: 740

config-replace:
  cmd.run:
    - cwd: /root/
    - name: ./config-replace.sh

ilias-setup:
  cmd.wait:
    - name: php /var/www/html/setup/setup.php install -y /var/ilias/data/ilias-config.json
    - watch:
      - cmd: config-replace

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