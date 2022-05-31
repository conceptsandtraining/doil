# salt 'doil.proxy' state.highstate saltenv=proxyservices
# salt-run state.event pretty=True

proxyservice_packages:
  pkg.installed:
    - pkgs:
      - nginx

/root/service-config.tpl:
  file.managed:
    - source: salt://proxyservices/service-config.tpl

/root/add-configuration.sh:
  file.managed:
    - source: salt://proxyservices/add-configuration.sh
    - mode: 755

/root/check-for-lost-minions.sh:
  file.managed:
    - source: salt://proxyservices/check-for-lost-minions.sh
    - mode: 755

/etc/nginx/conf.d/sites/mailserver.conf:
  file.managed:
    - source: salt://proxyservices/mailserver.conf

/etc/supervisor/conf.d/nginx.conf:
  file.managed:
    - source: salt://proxyservices/sv-nginx.conf

nginx_supervisor_signal:
  supervisord.running:
    - name: nginx
    - watch:
      - file: /etc/supervisor/conf.d/nginx.conf
