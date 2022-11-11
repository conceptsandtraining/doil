/var/www/html/data/ilias/client.ini.php:
  file.replace:
    - pattern: '^DEBUG = "0"'
    - repl: 'DEVMODE = "1"\nUSE_WHOOPS = "1"'
    - backup: false