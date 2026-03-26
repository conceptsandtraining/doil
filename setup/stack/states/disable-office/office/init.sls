{% set ilias_version = salt['grains.get']('ilias_version', '9') %}

{% if ilias_version | int < 10 %}
failure:
  test.fail_without_changes:
    - name: "OnlyOffice works only with ILIAS >= 10"
    - failhard: True
{% endif %}

disable_wopi:
  mysql_query.run:
    - database: ilias
    - query: "UPDATE settings SET value = 0 where keyword = 'wopi_activated';"

set_wopi_url:
  mysql_query.run:
    - database: ilias
    - query: "DELETE FROM settings WHERE keyword = 'wopi_discovery_url';"

drop_wopi_app_table:
  mysql_query.run:
    - database: ilias
    - query: "DROP TABLE IF EXISTS wopi_app;"

truncate_wopi_action_table:
  mysql_query.run:
    - database: ilias
    - query: "DELETE FROM wopi_action;"