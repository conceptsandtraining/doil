#!/bin/bash
if [ $ALLOW_OVERRIDE == 'All' ]; then
    /bin/sed -i 's/AllowOverride\ None/AllowOverride\ All/g' /etc/apache2/apache2.conf
fi

# enable php short tags:
/bin/sed -i "s/short_open_tag\ \=\ Off/short_open_tag\ \=\ On/g" /etc/php/7.0/apache2/php.ini

# Set PHP timezone
/bin/sed -i "s/\;date\.timezone\ \=/date\.timezone\ \=\ ${DATE_TIMEZONE}/" /etc/php/7.0/apache2/php.ini

# Run Postfix
/usr/sbin/postfix start

# Run MariaDB
#/usr/bin/mysqld_safe --timezone=${DATE_TIMEZONE}&

# Run Apache:
&>/dev/null /usr/sbin/apachectl -DFOREGROUND -k start
