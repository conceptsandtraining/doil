ilCron_packages:
  pkg.installed:
    - pkgs:
      - cron

/etc/logrotate.d/ilias:
  file.managed:
    - source: salt://ilCron/ilias_logrotate
    - user: root
    - group: root
    - mode: 750

ilias_logfile_cron:
  cron:
    - name: find /var/ilias/logs/ -type f -mtime +1 -delete
    - present
    - identifier: ILIAS_LOGFILE_CRON
    - user: root
    - hour: 4
    - minute: 0

ilias_cron:
  cron:
    - name: /usr/local/bin/ilias_cron.sh > /dev/null 2>&1
    - present
    - identifier: ILIAS_CRON
    - user: www-data
    - minute: '*/10'
    - require:
      - file: /usr/local/bin/ilias_cron.sh

/usr/local/bin/ilias_cron.sh:
  file:
    - managed
    - backup: minion
    - source: salt://ilCron/ilias_cron.sh
    - user: www-data
    - group: root
    - mode: 750
    - template: jinja
    - context:
      passwd: changeme
      cronuser: root
      path: /var/www/html/
      instance: ilias6
