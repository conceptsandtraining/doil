remove_use_whoops:
  file.line:
    - name: /var/www/html/data/ilias/client.ini.php
    - match: '^USE_WHOOPS'
    - mode: delete

add_use_whoops:
  file.line:
      - name: /var/www/html/data/ilias/client.ini.php
      - after: '^\[system\]'
      - before: '^ROOT_FOLDER_ID'
      - mode: insert
      - content: 'USE_WHOOPS = "1"'

remove_devmode:
  file.line:
    - name: /var/www/html/data/ilias/client.ini.php
    - match: '^DEVMODE'
    - mode: delete

add_devmode:
  file.line:
      - name: /var/www/html/data/ilias/client.ini.php
      - after: '^\[system\]'
      - before: '^ROOT_FOLDER_ID'
      - mode: insert
      - content: 'DEVMODE = "1"'
