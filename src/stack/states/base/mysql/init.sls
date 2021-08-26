{% set cpu = salt['grains.get']('num_cpus', '4') %}
{% set ram = salt['grains.get']('mem_total', '4096') %}
{% set mysql_password = salt['grains.get']('mysql_password', 'ilias') %}

mysql_packages:
  pkg.installed:
    - pkgs:
      - mariadb-server
      - supervisor
      - python3-mysqldb

/etc/mysql/mariadb.conf.d/50-server.cnf:
  file:
    - managed
    - source: salt://mysql/my.cnf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
        cpu: {{ cpu }}
        ram: {{ ram }}

/etc/supervisor/conf.d/mysql.conf:
  file.managed:
    - source: salt://mysql/mysql.conf
    - user: root
    - group: root
    - mode: 644

mysql_supervisor_signal:
  supervisord.running:
    - name: mysqld
    - watch:
      - file: /etc/supervisor/conf.d/mysql.conf
      - file: /etc/mysql/mariadb.conf.d/50-server.cnf

mysql_signal_wait:
  cmd.wait:
    - name: sleep 10
    - watch:
      - supervisord: mysql_supervisor_signal

mysql_grain:
  grains.present:
    - value: True
    - name: mysql

mysql_adduser:
  mysql_user.present:
    - name: ilias
    - host: 'localhost'
    - password: {{ mysql_password }}
    - unless:
      - fun: mysql_user.exists
      - name: 'ilias'

mysql_grant:
  mysql_grants.present:
    - grant: all privileges
    - user: ilias
    - database: '*.*'
    - grant_option: true
