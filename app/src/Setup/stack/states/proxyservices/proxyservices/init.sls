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

/etc/supervisor/conf.d/nginx.conf:
  file.managed:
    - source: salt://proxyservices/sv-nginx.conf

nginx_supervisor_reread:
  cmd.run:
    - name: supervisorctl reread
    - watch:
      - file: /etc/supervisor/conf.d/nginx.conf

nginx_supervisor_update:
  cmd.run:
    - name: supervisorctl update
    - watch:
        - cmd: nginx_supervisor_reread