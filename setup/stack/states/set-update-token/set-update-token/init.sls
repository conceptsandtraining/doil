{% set update_token = salt['grains.get']('update_token', '') %}

/etc/apache2/envvars:
  file.replace:
    - pattern: '^export UPDATE_TOKEN=.*$'
    - repl: 'export UPDATE_TOKEN={{ update_token }}'
    - append_if_not_found: True

restart_apache:
  cmd.run:
    - name: supervisorctl restart apache2