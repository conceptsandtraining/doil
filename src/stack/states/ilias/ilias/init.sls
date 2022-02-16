{% set doil_project_name = salt['grains.get']('doil_project_name', 'ilias') %}

{% if salt['grains.get']('doil_host_system', 'linux') == 'linux' %}
/var/www/html:
  file.directory:
    - user: www-data
    - group: www-data
    - mode: 755
    - makedirs: True

/var/ilias/data:
  file.directory:
    - user: www-data
    - group: www-data
    - mode: 755
    - makedirs: True

/var/ilias/logs:
  file.directory:
    - user: www-data
    - group: www-data
    - mode: 755
    - makedirs: True
{% endif %}

ilias_git_config:
  git.config_set:
    - name: core.fileMode
    - value: false
    - repo: /var/www/html