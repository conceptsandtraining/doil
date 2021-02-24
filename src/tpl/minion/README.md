# Instance %TPL_PROJECT_NAME%

This is an automatically created instance of %TPL_PROJECT_NAME%.

## Usage

Within your projectfolder (where this readme file is located) you can use following commands to manage your instance:

* `doil up` - starts the docker instance and adds the generated IP address to your `/etc/hosts` file
* `doil down` - stops the docker instance and removes the IP from your `/etc/hosts` file
* `doil login` - if the docker instance is started the you can login to your machine with this command
* See `man doil` for more information, commands and their usage

## Paths

* Path to data directory outside of ILIAS: `/var/ilias/data`
* Path to ILIAS log file: `/var/ilias/logs/ilias.log`
* Path to ILIAS error log folder: `/var/ilias/logs/error/`

### /etc/hosts

The host file will be written automatically when your container is started with `doil up`. However it is possible that some IP addresses overlap due to unknown circumstances. If your project is not available under `%TPL_PROJECT_NAME%.local` check your `/etc/hosts` file.

## Users and Password

The included database environment comes with following setup:

```
MYSQL_HOST: localhost
MYSQL_DB: ilias
MYSQL_USER: ilias
MYSQL_PASSWORD: ilias
```

If you chosed the automatic installation you can login to your ILIAS installation with following credentials:

```
User: root
Passwort: homer
```
