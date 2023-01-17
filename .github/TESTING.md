# Testing doil

Before a release doil needs to be tested deeply. For that we implemented a mandatory test protocoll which will additionally check all the functions of doil from a user perspective.

## Release Test Protocol

### Update

* [ ] Update should inform you, if not running as root
* [ ] Update should inform you, if sudo user isn't in docker group
* [ ] Update should inform you, if root has no access to docker-compose
* [ ] Update should inform you, if your operating system isn't Darwin or Linux
* [ ] Update should inform you, if you run a docker version lower than 19.03
* [ ] Update should inform you, if your php version is lower than 7.4
* [ ] Update should inform you, if you haven't installed php module zip
* [ ] Update should inform you, if you haven't installed php module dom
* [ ] Update should inform you, if you haven't installed composer
* [ ] Update should inform you, if you haven't installed git
* [ ] Change mail_password in setup/conf/doil.conf before update. After update, you should be able to login to http://doil/mails with www-data and the password you set.
* [ ] Update should only run, if a new version is detected
* [ ] Update runs completely without errors

### Setup

* [ ] Setup should inform you, if not running as root
* [ ] Setup should inform you, if port 80/443 are not free 
* [ ] Setup should inform you, if sudo user isn't in docker group
* [ ] Setup should inform you, if root has no access to docker-compose
* [ ] Setup should inform you, if your operating system isn't Darwin or Linux
* [ ] Setup should inform you, if you run a docker version lower than 19.03
* [ ] Setup should inform you, if your php version is lower than 7.4
* [ ] Setup should inform you, if you haven't installed php module zip
* [ ] Setup should inform you, if you haven't installed php module dom
* [ ] Setup should inform you, if you haven't installed composer
* [ ] Setup should inform you, if you haven't installed git
* [ ] Change mail_password in setup/conf/doil.conf before setup. After setup, you should be able to login to http://doil/mails with www-data and the password you set.
* [ ] Setup runs completely without errors

### Creating a new instance

* [ ] Instance can be created (CLI/Wizard)
* [ ] Instance can be created with specific target directory
* [ ] Instance can be created with xdebug support
* [ ] All states will be applied correctly
* [ ] Combination: ILIAS 7 + PHP 7.4 works
* [ ] Combination: ILIAS 8 + PHP 8.0 works
* [ ] ilServer works (certificates can be shown)
* [ ] Cron works (checked in ILIAS backend)
* [ ] Optional: Autoinstaller works for ILIAS 7+

### Import / Export

* [ ] An instance can be exported into ZIP file
* [ ] retrieved ZIP file can be imported into an existing instance
* [ ] retrieved ZIP file can be imported into a new instance

### Manage an existing instance

* [ ] Instance can be started
* [ ] All instances can be started with --all
* [ ] Instance is reachable from the browser
* [ ] It is possible to login via cli
* [ ] Instance contains the data when left
* [ ] Instance can be stopped
* [ ] All instance can be stopped with --all
* [ ] A state can be applied (PHP/Xdebug/Access)
* [ ] A state can be applied to all instances with `doil apply --all` (PHP/Xdebug/Access)
* [ ] Instance can be deleted
* [ ] All instances can be deleted with --all
* [ ] The directory of an instance can be display
* [ ] CLI commands can be executed via `doil exec <instance_name> "<cli command>"`

### Repository

* [ ] A repository can be added
* [ ] A repository can be deleted
* [ ] All repositories can be deleted with --all
* [ ] A repository can be updated
* [ ] All repositories can be updated with -all
* [ ] The list with the available repositories shows the actual repositories

### Managing the proxy server

* [ ] the server can be started
* [ ] the server can be stopped
* [ ] the server can be restarted
* [ ] the server can be pruned (config files)
* [ ] the configurations of the server can be reloaded
* [ ] it's possible to login via cli

### Managing the salt server

* [ ] the server can be started
* [ ] the server can be stopped
* [ ] the server can be restarted
* [ ] the server can be pruned (keys)
* [ ] it's possible to login via cli
* [ ] the available states can be listed

### Managing the mail server

* [ ] the server can be started
* [ ] the server can be stopped
* [ ] the server can be restarted
* [ ] it's possible to login via cli
* [ ] the password can be changed

### Additional functionalities

* [ ] Currently installed instances can be listed
* [ ] Currently running instances can be listed
* [ ] doil can be uninstalled (instances remain)
* [ ] doil can be uninstalled with --prune (no instances remain)
* [ ] Version can be displayed
* [ ] Each command has its help page

### Global User Support (Linux only)

* [ ] A new user can be added to the doil group
* [ ] A user can be removed from the doil group
* [ ] All users can be removed from the doil group with --all
* [ ] Registered users can be listed

### Log

* [ ] Doil should log into /var/log/doil/doil.log
* [ ] Salt should log into /var/log/doil/salt.log

## Environments

* [ ] Tested with Linux
* [ ] Tested with --global flag
* [ ] Optional: Tested with MacOS