{% set ilias_version = salt['grains.get']('ilias_version', '9') %}

apt_add_jq_tool:
  pkg.installed:
    - pkgs:
      - jq

rewrite_ilias_config:
  cmd.wait:
    - name: >
        jq -S '.http |= del(.https_autodetection)' ilias-config.json > new.json && mv new.json ilias-config.json
    - cwd: /var/ilias/data
    - watch:
      - pkg: apt_add_jq_tool

{%- if salt['file.file_exists']('/var/ilias/data/ilias/auth/saml/config/config.php') %}
rewrite_saml_config:
  cmd.run:
    - name: sed -i -e "s/'https:/'http:/g" /var/ilias/data/ilias/auth/saml/config/config.php
{%- endif %}

{% if ilias_version | int < 10 %}
update_ilias_lt_10:
  cmd.wait:
    - name: php setup/setup.php update -y /var/ilias/data/ilias-config.json
    - cwd: /var/www/html
    - watch:
      - cmd: rewrite_ilias_config
{% else %}
update_ilias_ge_10:
  cmd.wait:
    - name: php cli/setup.php update -y /var/ilias/data/ilias-config.json
    - cwd: /var/www/html
    - watch:
      - cmd: rewrite_ilias_config
{% endif %}

apt_remove_jq_tool:
  pkg.removed:
    - pkgs:
      - jq