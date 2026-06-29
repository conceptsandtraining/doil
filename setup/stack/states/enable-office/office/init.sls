{% set ilias_version = salt['grains.get']('ilias_version', '9') %}
{% set doil_domain = salt['grains.get']('doil_domain', 'http://doil/') %}

{% if ilias_version | int < 10 %}
failure:
  test.fail_without_changes:
    - name: "OnlyOffice works only with ILIAS >= 10"
    - failhard: True
{% endif %}

enable_wopi:
  mysql_query.run:
    - database: ilias
    - query: "DELETE FROM settings WHERE keyword = 'wopi_activated';INSERT INTO settings (module, keyword, value) VALUES ('common', 'wopi_activated', 1);"

set_wopi_url:
  mysql_query.run:
    - database: ilias
    - query: "DELETE FROM settings WHERE keyword = 'wopi_discovery_url';INSERT INTO settings (module, keyword, value) VALUES ('common', 'wopi_discovery_url', '{{ doil_domain.split('/')[:-1] | join('/') }}/office/hosting/discovery');"

/root/wopi.sql:
  file.managed:
    - source: salt://office/config/wopi.sql.j2
    - mode: "0444"
    - template: jinja
    - context:
      url: {{ doil_domain.split('/')[:-1] | join('/') }}

import_wopi_app_sql:
  cmd.run:
    - name: mysql ilias < /root/wopi.sql