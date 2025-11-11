reset-ilias-root-password:
  mysql_query.run:
    - database: ilias
    - query: "UPDATE usr_data SET passwd = '$2y$09$uhSHx5YHS6G1zv0gdTZfx.VNK482euQm2HmPd6cBhmOn3lgPd.NSC', passwd_salt = NULL, passwd_enc_type = 'bcryptphp' where login = 'root';"