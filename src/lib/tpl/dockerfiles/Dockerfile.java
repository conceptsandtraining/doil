FROM openjdk:8-jre-alpine
ARG BUILD_NO
RUN apk add --no-cache bash gettext curl
COPY conf/lucene/init.sh /usr/local/bin/
COPY conf/lucene/loop.sh /usr/local/bin/
RUN chmod -R 755 /usr/local/bin
EXPOSE 11111
CMD ["/usr/local/bin/init.sh"]
