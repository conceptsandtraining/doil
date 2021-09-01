# Instance %TPL_PROJECT_NAME%

This is an automatically created instance of %TPL_PROJECT_NAME%.

## Usage

Within your projectfolder (where this readme file is located)
you can use following commands to manage your instance:

* `doil up` - starts the docker instance
* `doil down` - stops the docker instance
* `doil login` - if the docker instance is started the you can
  login to your machine with this command
* See `man doil` for more information, commands and their usage

## Paths

* Path to data directory outside of ILIAS: `/var/ilias/data`
* Path to ILIAS log file: `/var/ilias/logs/ilias.log`
* Path to ILIAS error log folder: `/var/ilias/logs/error/`

### URL

The proxy server will automatically change its configuration when
using `doil up`. Your instance will be available under the address
`http://doil/%TPL_PROJECT_NAME%`

## Users and Password

The included database environment comes with following setup:

```
MYSQL_HOST: localhost
MYSQL_DB: ilias
MYSQL_USER: ilias
MYSQL_PASSWORD: %GRAIN_MYSQL_PASSWORD%
```

If the automatic installation was successful you can login to your ILIAS
installation with following credentials:

```
User: root
Passwort: homer
```

For the ILIAS user "cron" following password has been generated. Be sure that the user
has been added to your system.

```
%GRAIN_CRON_PASSWORD%
```

## Additional Information

You can find adminer at `http://doil/%TPL_PROJECT_NAME%/adminer`