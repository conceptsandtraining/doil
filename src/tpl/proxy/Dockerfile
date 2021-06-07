FROM debian:stable

RUN apt-get update
RUN apt-get install -y vim less virt-what net-tools procps nginx

RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]]