{% set doil_host_system = salt['grains.get']('doil_host_system', 'linux') %}

packages_check:
  pkg.installed:
    - pkgs:
      - ftp
      - curl
      - imagemagick
      - ghostscript
      - npm

{% if salt['grains.get']('doil_host_system', 'linux') == 'linux' %}
/var/www/html/:
  file.directory:
    - user: www-data
    - group: www-data
    - recurse:
      - user
      - group

/var/ilias/:
  file.directory:
    - user: www-data
    - group: www-data
    - recurse:
      - user
      - group
{% endif %}