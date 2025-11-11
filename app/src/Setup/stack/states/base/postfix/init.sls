#{% set fqdn = salt['grains.get']('id') %}
#{% set shortname = salt['grains.get']('host') %}

#{% set fqdn = localhost %}
#{% set shortname = localhost %}

install_postfix:
  pkg.installed:
    - name: postfix
    
/etc/postfix/main.cf:
  file.managed:
    - source: salt://postfix/main.cf
    - template: jinja
    - context:
      fqdn: localhost
      shortname: localhost

/etc/postfix/transport:
  file.managed:
    - source: salt://postfix/transport

/etc/mailname:
  file.managed:
    - source: salt://postfix/mailname
    - template: jinja
    - context:
      fqdn: localhost

/etc/aliases:
  file.managed:
    - source: salt://postfix/aliases

postmap /etc/postfix/transport:
  cmd.wait:
    - watch:
      - file: /etc/postfix/transport 

newaliases:
  cmd.wait:
    - watch:
      - file: /etc/aliases

restart_postfix:
  cmd.wait:
    - name: /etc/init.d/postfix restart
    - watch:
      - file: /etc/postfix/main.cf
      - file: /etc/postfix/transport
      - file: /etc/mailname
      - file: /etc/aliases
      - pkg: install_postfix
