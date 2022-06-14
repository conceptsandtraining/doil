proxy_on_minion_stop:
  local.cmd.run:
    - tgt: 'doil.proxy'
    - user: root
    - arg:
        - /root/check-for-lost-minions.sh {{ data['lost'] }}