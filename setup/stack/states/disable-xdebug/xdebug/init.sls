{% set maj = salt['cmd.shell']('php -r "echo PHP_MAJOR_VERSION;"')  %}
{% set min = salt['cmd.shell']('php -r "echo PHP_MINOR_VERSION;"')  %}

php{{ maj }}.{{ min }}:
  pkg.purged:
    - pkgs:
      - php{{ maj }}.{{ min }}-xdebug

/etc/php/{{ maj }}.{{ min }}/apache2/php.ini:
  file.replace:
    - pattern: '^; XDEBUG-START.*; XDEBUG-END$'
    - flags: ['DOTALL', 'MULTILINE']
    - repl: ''

apache2_supervisor_signal:
  cmd.run:
    - name: supervisorctl restart apache2