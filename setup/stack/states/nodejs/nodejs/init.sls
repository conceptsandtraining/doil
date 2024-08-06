
get_npm_by_curl:
  cmd.run:
    - name: curl -sL https://deb.nodesource.com/setup_16.x | bash -

install_node_js:
  cmd.run:
    - name: apt -y install nodejs
    - watch:
      - get_npm_by_curl

update_npm:
  cmd.run:
    - name: npm install -g npm@9.6.2
    - watch:
      - install_node_js

install_ilias_npm_packages:
  cmd.run:
    - name: cd /var/www/html && npm clean-install --ignore-scripts
    - watch:
      - update_npm