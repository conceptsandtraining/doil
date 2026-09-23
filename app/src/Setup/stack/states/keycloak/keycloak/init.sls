# salt 'doil.keycloak' state.highstate saltenv=keycloak
# salt-run state.event pretty=True

init_keycloak_api:
  cmd.run:
    - name: /opt/keycloak/bin/kcadm.sh config credentials --server http://localhost:8080 --realm master --user admin --password %TPL_OLD_ADMIN_PASSWORD%

change_admin_password:
  cmd.run:
    - name: /opt/keycloak/bin/kcadm.sh set-password -r master --username admin --new-password %TPL_NEW_ADMIN_PASSWORD%

# Please leave this in as an example for default user creation
# {% if salt["cmd.run"]("/opt/keycloak/bin/kcadm.sh get users -r master -q q=username:doil") == "[ ]" %}
# create_doil_user:
#  cmd.run:
#    - name: /opt/keycloak/bin/kcadm.sh create users -r master -s username=doil -s enabled=true
# {% endif %}
#
# change_doil_password:
#  cmd.run:
#    - name: /opt/keycloak/bin/kcadm.sh set-password -r master --username doil --new-password %TPL_USR_PASSWORD%

/root/delete_keycloak_client.sh:
  file.managed:
    - source: salt://keycloak/delete_keycloak_client.sh.j2
    - template: jinja
    - context:
      new_admin_password: %TPL_NEW_ADMIN_PASSWORD%
    - user: root
    - group: root
    - mode: 744