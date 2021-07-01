{% set apache_conf = salt['pillar.get']('web:apache_conf', 'salt://apache/default') %}
{% set apache_docroot = salt['pillar.get']('web:docroot', '/var/www/html/') %}

apache_packages:
  pkg.installed:
    - pkgs:
      - apache2
      - supervisor

/etc/apache2/sites-available/000-default.conf:
  file.managed:
    - source: {{ apache_conf }}
    - user: root
    - group: root
    - mode: 644

/root/apache-config-replace.sh:
  file.managed:
    - source: salt://base/apache-config-replace.sh
    - user: root
    - group: root
    - mode: 740

config-replace:
  cmd.run:
    - cwd: /root/
    - name: ./apache-config-replace.sh

/etc/apache2/sites-enabled/000-default.conf:
  file.symlink:
    - target: /etc/apache2/sites-available/000-default.conf

/etc/supervisor/conf.d/apache2.conf:
  file.managed:
    - source: salt://apache/apache.conf
    - user: root
    - group: root
    - mode: 644

apache_supervisor_signal:
  supervisord.running:
    - name: apache2
    - restart: True
    - watch:
      - file: /etc/supervisor/conf.d/apache2.conf
      - file: /etc/apache2/sites-enabled/000-default.conf

apache_grain:
  grains.present:
    - value: True
    - name: apache
