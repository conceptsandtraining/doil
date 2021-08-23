location /%DOMAIN%/ {
    proxy_pass       http://%IP%/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP  $remote_addr;
    proxy_set_header X-Forwarded-For $remote_addr;

    rewrite          ^/%DOMAIN%/(.*) /%DOMAIN%/$1 break;
}