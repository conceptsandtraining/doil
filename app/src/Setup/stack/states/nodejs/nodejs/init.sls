{% set ilias_version = salt['grains.get']('ilias_version', '9') %}
{% if ilias_version | int < 10 %}
  {% set node = 'https://deb.nodesource.com/setup_16.x' %}
  {% set npm = 'npm@9.6.2' %}
{% else %}
  {% set node = 'https://deb.nodesource.com/setup_22.x' %}
  {% set npm = 'npm@10.9.3' %}
{% endif %}

get_npm_by_curl:
  cmd.run:
    - name: curl -sL {{ node }} | bash -

install_node_js:
  cmd.run:
    - name: apt -y install nodejs
    - watch:
      - get_npm_by_curl

update_npm:
  cmd.run:
    - name: npm install -g {{ npm }}
    - watch:
      - install_node_js

install_ilias_npm_packages:
  cmd.run:
    - name: cd /var/www/html && npm clean-install --ignore-scripts
    - watch:
      - update_npm