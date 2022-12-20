{% set password = salt['grains.get']('roundcube_password', '$6$bU5Mi3igaeRp80Hk$rIWWJhdCPYlMYlwfd7aRm/NlYoIJ1ESQkRP0RvMb.XdY87FxgfT4SK6oiVKhzRDOxRxwv7sQ/I3kvvLcpKcCD1')  %}

www-data:
  user.present:
    - password: '{{ password }}'