# Testing doil

Before a release doil needs to be tested deeply. For that we implemented a mandatory test protocoll which will additionally check all the functions of doil from a user perspective.

## Release Test Protocoll

### Manage an existing instance

* [] Instance can be started
* [] Instance is reachable from the browser
* [] It is possible to login via cli
* [] Instance contains the data when left
* [] Instance can be stopped
* [] Instance can be deleted
* [] The active directory can be switched to an instance

### Creating a new instance

* [] 
* [] ILIAS 7 + PHP 7.3
* [] ILIAS 8 + PHP 8.0
* [] ilServer
* [] Cron
* [] autoinstaller

### Repository

* [] A repository can be added
* [] A repository can be deleted
* [] A repository can be updated
* [] The list with the available repositories shows the actual repositories

### Import and export



### Managing the proxy server

* [] the server can be started
* [] the server can be stopped
* [] the server can be restarted
* [] the server can be pruned
* [] the configurations of the server can be reloaded
* [] Changing host is possible
* [] it's possible to login via cli

### Managing the salt server

* [] the server can be started
* [] the server can be stopped
* [] the server can be restarted
* [] the server can be pruned
* [] it's possible to login via cli
* [] the available states can be listed

### Additional functionalities

* [] Currently installed instances can be listed
* [] Currently running instances can be listed
* [] doil can be deinstalled (instances remain)

### Global User Support (Linux only)

* [] A new user can be added to the doil group
* [] A user can be removed from the doil group
* [] Registered users can be listed

## Environments

* [] Tested with Linux
* [] Tested with --global flag
* [] Tested with Windows
(* [] Tested with MacOS)