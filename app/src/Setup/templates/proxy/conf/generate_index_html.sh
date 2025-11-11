#!/bin/bash

RESULT=""
SERVER_NAME=$(sed -n -e '/server_name/p' /etc/nginx/conf.d/local.conf | grep -v '#' | head -n 1 | cut -d ' ' -f6 | cut -d ';' -f1)
readarray -t INSTANCES < <(ls /etc/nginx/conf.d/sites)
for i in "${INSTANCES[@]}"
do
        NAME=$(echo $i | cut -d . -f1)
        RESULT=${RESULT}"<li><a href=\"http://${SERVER_NAME}/${NAME}/\" target=\"_blank\">${SERVER_NAME}/${NAME}</a></li>"
done

KEYCLOAK="<li><a href=\"http://${SERVER_NAME}/keycloak/\" target=\"_blank\">${SERVER_NAME}/keycloak</a></li>"
MAIL="<li><a href=\"http://${SERVER_NAME}/mails/\" target=\"_blank\">${SERVER_NAME}/mails</a></li>"

cat << EOF > /tmp/index.html
<!doctype html>
<html lang="en">
  <head>
    <title>Doil-Server-Status</title>
    <meta name='robots' content='noindex,follow' />
    <style>
      body { font-family: monospace; background: #002b36; color: #586e75; }
      a { color: #2aa198; }
      h2 { color: #268bd2; margin-bottom: -10px; }
      p { color: #859900; margin-top: 0px; }
      ul.index { margin-top: 0px; margin-bottom: 15px; }
      li { color: #2aa198; }
    </style>
  </head>
  <body>
  <h2 id="instances">Keycloak Instance</h2>
      <p>&nbsp;</p>
      <ul class="index">
      $(echo "${KEYCLOAK}")
      </ul>
  <h2 id="instances">Mail Instance</h2>
      <p>&nbsp;</p>
      <ul class="index">
      $(echo "${MAIL}")
      </ul>
  <h2 id="instances">Doil Instances</h2>
      <p>&nbsp;</p>
      <ul class="index">
      $(echo "${RESULT}")
      </ul>
  </body>
  </html>
EOF

cp /tmp/index.html /var/www/html/index.html