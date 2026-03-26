{% set ilias_version = salt['grains.get']('ilias_version', '9') %}

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
    - query: "DELETE FROM settings WHERE keyword = 'wopi_discovery_url';INSERT INTO settings (module, keyword, value) VALUES ('common', 'wopi_discovery_url', 'http://172.24.0.251/hosting/discovery');"

/root/wopi.sql:
  file.managed:
    - source: salt://office/config/wopi.sql
    - mode: "0444"

import_wopi_app_sql:
  cmd.run:
    - name: mysql ilias < /root/wopi.sql