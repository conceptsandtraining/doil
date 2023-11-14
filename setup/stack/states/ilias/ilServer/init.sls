{% set ilias_version = salt['grains.get']('ilias_version', '9') %}

ilServer_packages:
  pkg.installed:
    - pkgs:
      - default-jre

javaport_grain:
  grains.present:
    - name: javaport
    - value: 11111

{% if ilias_version | int < 10 %}
/var/www/html/Services/WebServices/RPC/lib/ilServer.ini:
  file:
    - managed
    - source: salt://ilServer/ilServer.ini
    - user: www-data
    - group: www-data
    - mode: 644
    - template: jinja
    - context:
      path: /var/www/html/ilias.ini.php
{% else %}
/var/www/html/components/ILIAS/WebServices/RPC/lib/ilServer.ini:
  file:
    - managed
    - source: salt://ilServer/ilServer.ini
    - user: www-data
    - group: www-data
    - mode: 644
    - template: jinja
    - context:
      path: /var/www/html/scripts/ilias.ini.php
{% endif %}
      
/etc/supervisor/conf.d/ilServer.conf:
  file:
    - managed
    - source: salt://ilServer/ilServer.conf
    - user: root
    - group: root
    - mode: 755
    - template: jinja

supervisor_ilserver_signal:
  supervisord.running:
    - name: ilServer
    - watch:
      - file: /etc/supervisor/conf.d/ilServer.conf

ilserver_grain:
  grains.present:
    - name: ilServer
    - value: True

