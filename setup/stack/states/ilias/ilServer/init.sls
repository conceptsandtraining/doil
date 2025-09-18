{% set ilias_version = salt['grains.get']('ilias_version', '9') %}

ilServer_packages:
  pkg.installed:
    - pkgs:
      - default-jre
      {% if ilias_version | int >= 10 %}
      - maven
      {% endif %}

javaport_grain:
  grains.present:
    - name: javaport
    - value: 11111

{% if ilias_version | int < 10 %}
/var/www/html/Services/WebServices/RPC/lib/ilServer.ini:
  file.managed:
    - source: salt://ilServer/ilServer.ini
    - user: www-data
    - group: www-data
    - mode: 644

ilserver_conf_lt_10:
  file.managed:
    - name: /etc/supervisor/conf.d/ilServer.conf
    - source: salt://ilServer/ilServer.conf
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - context:
        ilserver_jar_path: /var/www/html/Services/WebServices/RPC/lib/ilServer.jar
        ilserver_ini_path: /var/www/html/Services/WebServices/RPC/lib/ilServer.ini
{% else %}
/var/www/html/components/ILIAS/WebServices/RPC/lib/ilServer.ini:
  file.managed:
    - source: salt://ilServer/ilServer.ini
    - user: www-data
    - group: www-data
    - mode: 644

install_ilserver_jar:
  cmd.run:
    - name: mvn clean install
    - cwd: /var/www/html/components/ILIAS/WebServices/RPC/lib

move_jar_to_ilias:
  cmd.run:
    - name: mv /var/www/html/components/ILIAS/WebServices/RPC/lib/target/ilServer.jar /var/ilias && rm -rf /var/www/html/components/ILIAS/WebServices/RPC/lib/target/ilServer.jar

ilserver_conf_ge_10:
  file.managed:
    - name: /etc/supervisor/conf.d/ilServer.conf
    - source: salt://ilServer/ilServer.conf
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - context:
        ilserver_jar_path: /var/ilias/ilServer.jar
        ilserver_ini_path: var/www/html/components/ILIAS/WebServices/RPC/lib/ilServer.ini
{% endif %}

supervisor_ilserver_signal:
  supervisord.running:
    - name: ilServer
    - watch:
      - file: /etc/supervisor/conf.d/ilServer.conf

ilserver_grain:
  grains.present:
    - name: ilServer
    - value: True

