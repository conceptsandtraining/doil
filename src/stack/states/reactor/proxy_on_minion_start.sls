proxy_on_minion_start:
  local.cmd.run:
    - tgt: 'doil.proxy'
    - user: root
    - arg:
      - /root/add-configuration.sh {{ data['data']['ip'] }} {{ data['data']['hostname'] }}