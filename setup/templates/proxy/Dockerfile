FROM debian:11

RUN apt-get update && apt-get install -y supervisor salt-minion
RUN apt-get update && apt-get install -y vim nano less virt-what net-tools procps cron

RUN touch crontab.tmp \
    && echo '*/1 * * * * /root/generate_index_html.sh > /dev/null' > crontab.tmp \
    && crontab crontab.tmp \
    && rm -rf crontab.tmp

EXPOSE 80 443

COPY conf/run-supervisor.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/run-supervisor.sh
CMD ["/usr/local/bin/run-supervisor.sh"]
