ilServer_packages:
  pkg.installed:
    - pkgs:
      - default-jre

javaport_grain:
  grains.present:
    - name: javaport
    - value: 11111

/var/www/html/Services/WebServices/RPC/lib/ilServer.ini:
  file:
    - managed
    - source: salt://ilServer/ilServer.ini
    - user: www-data
    - group: www-data
    - mode: 644
    - template: jinja
    - context:
      port: 11111
      path: /var/www/html
      clientid: ilias6
      ip: salt['grains.get']('ip_interfaces')['eth0'][0]
      
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

