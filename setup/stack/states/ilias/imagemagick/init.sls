/etc/ImageMagick-6/policy.xml:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://ilias/imagemagick/policy.xml

restart_apache:
  cmd.wait:
    - name: supervisorctl restart apache2
    - watch:
        - file: /etc/ImageMagick-6/policy.xml