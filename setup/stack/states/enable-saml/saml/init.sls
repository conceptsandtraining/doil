{% set doil_domain = salt['grains.get']('doil_domain') %}
{% set host_name = salt['grains.get']('host') %}
{% set mpass = salt['grains.get']('mpass') %}
{% set samlpass = salt['grains.get']('samlpass', 'abcdef123456!!$') %}
{% set samlsalt = salt['grains.get']('samlsalt', 'mc5tbaeuwn8mpxfx07sxq2wv2vi4utsw') %}
{% set ilias_version = salt['grains.get']('ilias_version', '9') %}
{% if ilias_version | int < 10 %}
  {% set meta_url = '/Services/Saml/lib/metadata.php?client_id=ilias' %}
{% else %}
  {% set meta_url = '/metadata.php?client_id=ilias' %}
{% endif %}

/var/ilias/data/ilias/auth/saml/config/authsources.php:
  file.managed:
    - source: salt://saml/authsources.php.j2
    - makedirs: True
    - template: jinja
    - context:
      ilias_http_path: {{ doil_domain }}
    - user: root
    - group: root
    - mode: 644

/var/ilias/data/ilias/auth/saml/config/config.php:
  file.managed:
    - source: salt://saml/config.php.j2
    - makedirs: True
    - template: jinja
    - context:
      ilias_http_path: {{ doil_domain }}
      samlsecretsalt: {{ samlsalt }}
      mpass: {{ mpass }}
      samlpass: {{ samlpass }}
      host_name: {{ host_name }}
    - user: root
    - group: root
    - mode: 644

/var/ilias/cert:
  file.directory:
    - user: www-data
    - group: www-data
    - dir_mode: 755

install_certs:
  cmd.run:
    - name: openssl req -newkey rsa:3072 -new -x509 -days 3652 -nodes -out saml.crt -keyout saml.pem -batch && chown -R www-data:www-data .
    - cwd: /var/ilias/cert
    - require:
        - file: /var/ilias/cert

{% if ilias_version | int < 10 %}
/var/www/html/SetIdp.php:
  file.managed:
    - source: salt://saml/SetIdp.php.j2
    - template: jinja
    - context:
      ilias_http_path: {{ doil_domain }}
      idp_meta: %TPL_IDP_META%
      keycloak_host_name: %TPL_KEYCLOAK_HOSTNAME%
    - user: root
    - group: root
    - mode: 644

init_ilias_idp_lt10:
  cmd.run:
    - name: php SetIdp.php; rm SetIdp.php
    - cwd: /var/www/html
    - require:
        - file: /var/www/html/SetIdp.php
{% else %}
/var/www/html/public/SetIdpV10.php:
  file.managed:
    - source: salt://saml/SetIdpV10.php.j2
    - template: jinja
    - context:
      ilias_http_path: {{ doil_domain }}
      idp_meta: %TPL_IDP_META%
      keycloak_host_name: %TPL_KEYCLOAK_HOSTNAME%
    - user: root
    - group: root
    - mode: 644

init_ilias_idp:
  cmd.run:
    - name: php SetIdpV10.php; rm SetIdpV10.php
    - cwd: /var/www/html/public
    - require:
        - file: /var/www/html/public/SetIdpV10.php
{% endif %}

/root/addInstanceToKeycloak.php:
  file.managed:
    - source: salt://saml/addInstanceToKeycloak.php.j2
    - template: jinja
    - context:
      server_host_name: %TPL_KEYCLOAK_HOSTNAME%
      admin_password: %TPL_ADMIN_PASSWORD%
      meta_url: {{ doil_domain }}{{ meta_url }}
    - user: root
    - group: root
    - mode: 744

addInstanceToKeycloak:
  cmd.run:
    - name: php addInstanceToKeycloak.php
    - cwd: /root
    - runas: root
    - require:
        - file: /root/addInstanceToKeycloak.php
