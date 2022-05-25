postfix_on_minion_start:
  local.cmd.run:
    - tgt: 'doil.postfix'
    - user: root
    - arg:
      - /root/check-postbox-configuration.sh {{ data['data']['hostname'] }}