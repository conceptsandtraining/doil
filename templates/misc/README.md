# Instance %TPL_FOLDER%

This is an automatically created instance of %TPL_TYPE%.

## Client ID

In order to get lucene work you need to install %TPL_TYPE% with the name `ilias`

## IPs

Your servers are available on following addresses:

Service | IP | Host | Port
--- | --- | --- | ---
Database | %TPL_SUBNET_BASE%.2 | none | 3306
phpMyAdmin | %TPL_SUBNET_BASE%.3 | pma.%TPL_FOLDER%.local | 80
Webserver | %TPL_SUBNET_BASE%.4 | %TPL_FOLDER%.local | 80
Lucene | %TPL_SUBNET_BASE%.5 | none | 11111

### /etc/hosts

If you chosed not to add the hosts information to the /etc/hosts file. Add following lines to your host files:

```
### %TPL_FOLDER% start
%TPL_SUBNET_BASE%.4 %TPL_FOLDER%.local
%TPL_SUBNET_BASE%.3 pma.%TPL_FOLDER%.local
### %TPL_FOLDER% end
```

## User and Password

The included database environment comes with following setup:

```
MYSQL_USER: root
MYSQL_PASSWORD: ilias
MYSQL_ROOT_PASSWORD: ilias
```

A database is not created and must be during the installation of ILIAS
