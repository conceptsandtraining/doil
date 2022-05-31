/root/salt-startup.sh:
  file.managed:
    - source: salt://startup/salt-startup.sh
    - mode: 755

/etc/supervisor/conf.d/startup.conf:
  file.managed:
    - source: salt://startup/startup.conf

startup_supervisor_signal:
  supervisord.running:
    - name: startup
