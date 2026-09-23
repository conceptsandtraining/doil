/etc/ImageMagick-7/policy.xml:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://imagemagick/policy.xml

restart_apache:
  cmd.wait:
    - name: supervisorctl restart apache2
    - watch:
        - file: /etc/ImageMagick-7/policy.xml