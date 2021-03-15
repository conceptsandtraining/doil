/var/www/html:
  file.directory:
    - user: www-data
    - group: www-data
    - mode: 755
    - makedirs: True

/var/ilias/data:
  file.directory:
    - user: www-data
    - group: www-data
    - mode: 755
    - makedirs: True

/var/ilias/logs:
  file.directory:
    - user: www-data
    - group: www-data
    - mode: 755
    - makedirs: True

ilias_git_config:
  git.config_set:
    - name: core.fileMode
    - value: false
    - repo: /var/www/html

#/var/ilias/data/ilias-config.json:
#  file.managed:
#    - source: salt://ilias/ilias-config.json
#    - template: jinja
#    - context:
#      client_id: ilias
#      master_password: ilias
#      server_timezone: 'Europe/Berlin'
#      db_user: ilias
#      db_name: ilias
#      db_type: 'innodb'
#      db_create: 'true'
#      db_pass: ilias
#      data_dir: /var/ilias/data
#      contact_firstname: 'CaT'
#      contact_lastname: 'Concepts and Training GmbH'
#      contact_mail: 'noreply@concepts-and-training.de'
#      language: 'de'
#      log_dir: /var/ilias/logs
#      http_path: http://ilias.local
#    - user: www-data
#    - group: www-data
#    - mode: 640

#ilias-setup:
#  cmd.wait:
#    - name: "php /var/www/html/setup/setup.php install -y /var/ilias/data/ilias-config.json"
#    - watch: 
#      - cmd: ilias-composer-install