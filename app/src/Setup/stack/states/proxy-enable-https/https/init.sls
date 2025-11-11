# This state sets up the necessary certificates so that you can operate your proxy with https.
# The prerequisite is that your proxy is already publicly accessible and the necessary DNS entries are available.
# This state must be executed on the salt master. The following command is used for this.
# Please note that you must provide your email address.
#
# salt 'doil.proxy' state.highstate saltenv=proxy-enable-https pillar='{"email": "<your_email>", "domain" = "<your_domain>"}'
# Example:
# salt 'doil.proxy' state.highstate saltenv=proxy-enable-https pillar='{"email": "dweise@cfoobar.de", "domain": "test.foo.de"}'
#
# After applying the state, it is important that you commit the new proxy status to the docker image on the docker host.
# To do this, run the following command on the Docker host.
#
# docker commit doil_proxy doil_proxy:stable
#
# Please ensure to run 'doil apply <instance_name> enable-https' on each doil ILIAS instance,
# so https take effect in ILIAS.

{% set email = salt['pillar.get']('email', '') %}
{% set domain = salt['pillar.get']('domain', '') %}

{% if email != "" %}
https_packages:
  pkg.installed:
    - pkgs:
      - cron
      - certbot
      - python3-certbot-nginx

install_cert:
  cmd.run:
    - name: certbot -n --nginx --agree-tos --email {{ email }} --domains {{ domain }}
    - runas: root

cert_renew_by_cron:
  cron.present:
    - user: root
    - name: certbot renew
    - hour: 3
{% else %}
custom_raise:
  test.fail_without_changes:
    - msg: "Missing email! Please use this command: salt 'doil.proxy' state.highstate saltenv=proxy-enable-https pillar='{\"email\": \"<your_email>\", \"domain\": \"<your_domain>\"}'"
    - failhard: True
{% endif %}