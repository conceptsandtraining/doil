# Testing doil

Before a release doil needs to be tested deeply. For that we implemented a mandatory test protocoll which will additionally check all the functions of doil from a user perspective.

## Release Test Protocoll

### Creating a new instance

* [ ] Instance can be created
* [ ] Instance can be created with specific target directory
* [ ] All states will be applied correctly
* [ ] Combination: ILIAS 7 + PHP 7.3 works
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
* [ ] Instance is reachable from the browser
* [ ] It is possible to login via cli
* [ ] Instance contains the data when left
* [ ] Instance can be stopped
* [ ] A state can be applied
* [ ] Instance can be deleted
* [ ] The directory of an instance can be display

### Repository

* [ ] A repository can be added
* [ ] A repository can be deleted
* [ ] A repository can be updated
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

### Additional functionalities

* [ ] Currently installed instances can be listed
* [ ] Currently running instances can be listed
* [ ] doil can be deinstalled (instances remain)
* [ ] Version can be displayed
* [ ] Each command has its help page

### Global User Support (Linux only)

* [ ] A new user can be added to the doil group
* [ ] A user can be removed from the doil group
* [ ] Registered users can be listed

## Environments

* [ ] Tested with Linux
* [ ] Tested with --global flag
* [ ] Tested with Windows
* [ ] Optional: Tested with MacOS