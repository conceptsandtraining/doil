{%- if salt['file.file_exists' ]('/var/www/html/CI/tools/compile-skins.sh') %}
compile_skins:
  cmd.run:
    - name: /var/www/html/CI/tools/compile-skins.sh
    - cwd: /var/www/html
    - runas: root
{%- endif %}
empty:
  cmd.run:
    - name: echo ''