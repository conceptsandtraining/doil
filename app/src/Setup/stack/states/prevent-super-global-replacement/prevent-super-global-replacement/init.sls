{% set ilias_version = salt['grains.get']('ilias_version', '9') %}

{% if ilias_version | int >= 8 %}
{% if ilias_version | int < 10 %}
/var/www/html/data/ilias/client.ini.php:
  file.blockreplace:
    - marker_start: '[server]'
    - marker_end: '[client]'
    - content: "start = \"./login.php\"\nprevent_super_global_replacement = \"1\"\n\n"
{% else %}
/var/www/html/public/data/ilias/client.ini.php:
  file.blockreplace:
    - marker_start: '[server]'
    - marker_end: '[client]'
    - content: "start = \"./login.php\"\nprevent_super_global_replacement = \"1\"\n\n"
{% endif %}
{% endif %}