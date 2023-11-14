{% set doil_domain = salt['grains.get']('doil_domain', 'http://ilias.local') %}
{% set doil_project_name = salt['grains.get']('doil_project_name', 'ilias') %}
{% set ilias_version = salt['grains.get']('ilias_version', '9') %}

apache_packages:
  pkg.installed:
    - pkgs:
      - apache2
      - supervisor

{% if ilias_version | int < 10 %}
sites_available_lt_10:
  file.managed:
    - name: /etc/apache2/sites-available/000-default.conf
    - source: salt://apache/default
    - template: jinja
    - context:
      doil_project_name: {{ doil_project_name }}
{% else %}
sites_available_ge_10:
  file.managed:
    - name: /etc/apache2/sites-available/000-default.conf
    - source: salt://apache/default_ilias10
    - template: jinja
    - context:
      doil_project_name: {{ doil_project_name }}
{% endif %}

/etc/apache2/sites-enabled/000-default.conf:
  file.symlink:
    - target: /etc/apache2/sites-available/000-default.conf

/etc/apache2/mods-enabled/rewrite.load:
  file.symlink:
    - target: /etc/apache2/mods-available/rewrite.load

/etc/supervisor/conf.d/apache2.conf:
  file.managed:
    - source: salt://apache/apache.conf

apache_supervisor_signal:
  supervisord.running:
    - name: apache2
    - restart: True
    - user: root
    - watch:
      - file: /etc/supervisor/conf.d/apache2.conf
      - file: /etc/apache2/sites-enabled/000-default.conf

restart_apache:
  cmd.run:
    - name: supervisorctl restart apache2
    - watch:
      - apache_supervisor_signal

apache_grain:
  grains.present:
    - value: True
    - name: apache
