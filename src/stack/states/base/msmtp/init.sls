msmtp-mta:
  pkg.installed
  
/etc/msmtprc:
  file.managed:
    - source: salt://msmtp/msmtp.conf.j2
    - template: jinja
    - context:
      mailname: doil.cat06.de
      smarthost: 172.24.0.253
    - user: root
    - group: root
    - mode: 644