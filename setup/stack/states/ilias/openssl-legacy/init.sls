/etc/ssl/openssl.cnf:
  file.managed:
    - source: salt://openssl-legacy/openssl.cnf
    - user: root
    - group: root
    - mode: 644

openssl_legacy_restart_apache_after_update:
  cmd.wait:
    - name: supervisorctl restart apache2
    - watch:
        - file: /etc/ssl/openssl.cnf