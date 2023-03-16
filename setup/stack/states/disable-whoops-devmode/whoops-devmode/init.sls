remove_use_whoops:
  file.line:
    - name: /var/www/html/data/ilias/client.ini.php
    - match: '^USE_WHOOPS'
    - mode: delete

remove_devmode:
  file.line:
    - name: /var/www/html/data/ilias/client.ini.php
    - match: '^DEVMODE'
    - mode: delete