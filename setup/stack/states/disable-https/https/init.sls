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

update_ilias:
  cmd.wait:
    - name: php setup/setup.php update -y /var/ilias/data/ilias-config.json
    - cwd: /var/www/html
    - watch:
      - cmd: rewrite_ilias_config

apt_remove_jq_tool:
  pkg.removed:
    - pkgs:
      - jq