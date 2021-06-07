server {
    listen 80;
    listen 443 ssl http2;
    server_name doil;

    location /%DOMAIN%/ {
        proxy_pass http://%IP%/;
    }

    access_log off;
    error_log  /var/log/nginx/error.log error;
}
