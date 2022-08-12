/var/www/html/data/ilias/client.ini.php:
  file.replace:
    - pattern: '^DEBUG = "0"'
    - repl: 'DEBUG = "0"\nUSE_WHOOPS = "1"'
    - backup: false