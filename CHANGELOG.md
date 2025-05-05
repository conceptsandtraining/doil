# Changelog

## 20250505
## What's Changed
* add robots.txt to proxy
* add robots meta tag for doil status site
* strg-c now cancel doil apply
* add php-intl to package list
* add php8.4

## 20250404
## What's Changed
* adjust proxy settings

## 20250226
## What's Changed
* istribute update token, and enable doil to trigger instance updates via url

## 20250217
## What's Changed
* fix the delete and set idp scripts

## 20250130
## What's Changed
* add 20250130
* doil: Fix typo
* remove typo that results in wrong http url
* explicit check for true

## 20241206
## What's Changed
* fix name extraction

## 20241205
## What's Changed
* keycloak: ensure instances work with https

## 20241113
## What's Changed
* add keycloak server
* add keycloak commands (down/login/restart/up)
* add saml states (enable-saml/disable-saml)
* add new state 'prevent-super-global-replacement'

## 20241104
## What's Changed
* update salt urls

## 20241010
## What's Changed
* execute proxy command only if instance is up
* add 'Options -Indexes' to default site

## 20240930
## What's Changed
* add captainhook states
* longer sleep between 'docker commit' and 'settinsg premissions'
* use correct pathes during import command

## 20240926
## What's Changed
* php: add version 8.3

## 20240902
## What's Changed
* add support for ilias 10 exports
* also export branches with no matching doil repo

## 20240807
## What's Changed
* change path for minion_master.pub

## 20240806
## What's Changed
* move nodejs step before composer step and change execution dir in nodejs state

## 20240801
## What's Changed
* fix problems with the ILIAS database password

## 20240628
## What's Changed
* use Salt Repos for salt-master and salt-minion
* better salt key handling
* !! Attention: doil needs to be reinstalled !!

## 20240617
## What's Changed
* update of an instance can now be triggered by url

## 20240604
## What's Changed
* CSP Rules per instance

## 20240422
## What's Changed
* fix typo in apache 000-default
* fix import/export bug if no skin folder exists
* fix password substitution for ilias-config.json in import command
* up/down <instance> immediately update proxy status page


## 20240411
## What's Changed
* improve performance of import/export
* check for buildx/docker compose during install/update
* add a status web page that list all active doil instances


## 20240307 
## What's Changed
* master compose/buildx: adjust docker calls to the new docker api by @daniwe4 in https://github.com/conceptsandtraining/doil/pull/415

Danger!!!
Please ensure that Docker is installed as described in this link. https://docs.docker.com/engine/install/ubuntu/
Adapt the link accordingly for a different OS.

**Full Changelog**: https://github.com/conceptsandtraining/doil/compare/20240214...20240307


## 20240214
## What's Changed
* master proxy-enable-https: 409 add domain as param by @daniwe4 in https://github.com/conceptsandtraining/doil/pull/410
* master Import/Export:411 ensure to export current branch, php version, repository name and url by @daniwe4 in https://github.com/conceptsandtraining/doil/pull/412
* master composer: install composer programmatically by @daniwe4 in https://github.com/conceptsandtraining/doil/pull/414

**Full Changelog**: https://github.com/conceptsandtraining/doil/compare/20231116...20240214


## 20231116 Hotfix: Delete Command
## What's Changed
* master delete: 407 fix error while deleting running container by @daniwe4 in https://github.com/conceptsandtraining/doil/pull/408

**Full Changelog**: https://github.com/conceptsandtraining/doil/compare/20231115...20231116


## 20231115 Enable Ilias10 Installation
## What's Changed
* master trunk: apply changes to install ilias10 by @daniwe4 in https://github.com/conceptsandtraining/doil/pull/406

**Full Changelog**: https://github.com/conceptsandtraining/doil/compare/20231114...20231115


## 20231114 Delete only with sudo
## What's Changed
* master Delete: 403 delete command now requires root privileges by @daniwe4 in https://github.com/conceptsandtraining/doil/pull/404

**Full Changelog**: https://github.com/conceptsandtraining/doil/compare/20231102...20231114


## 20231102 Enable Ilias10 Support
Fixed a bug that prevented ILIAS10 (trunk) from being installed.
Make update routine more robust.


## 20231024
## What's Changed

- local branches are now kept up to date
- root also has git save dirs
- states now have a description
- xdebug now logs to a writable location
- doil instances received a restart command
- new states enable/disable https
- export can be triggered by cron
- and other little things for better multi user support


## 20230815 Doil over PHP container
## What's Changed
* Doil into container by @daniwe4 in https://github.com/conceptsandtraining/doil/pull/347
* master states:295 add a new state 'reset-ilias-root-password' by @daniwe4 in https://github.com/conceptsandtraining/doil/pull/348
* master cron: rm unecessary if statement by @daniwe4 in https://github.com/conceptsandtraining/doil/pull/351
* master README: 350 remove typo by @daniwe4 in https://github.com/conceptsandtraining/doil/pull/352
* master README: 349 extend the removal tips by @daniwe4 in https://github.com/conceptsandtraining/doil/pull/353
* master setup: fix source handling by @daniwe4 in https://github.com/conceptsandtraining/doil/pull/354
* master setup: fix composer lock file handling by @daniwe4 in https://github.com/conceptsandtraining/doil/pull/355
* master setup: only use realpath if something exists by @daniwe4 in https://github.com/conceptsandtraining/doil/pull/356
* Master fix realpath by @daniwe4 in https://github.com/conceptsandtraining/doil/pull/357
* master fix mariadb first start by @daniwe4 in https://github.com/conceptsandtraining/doil/pull/358
* master fix mariadb start by @daniwe4 in https://github.com/conceptsandtraining/doil/pull/361
* master mysql: fix mysql on update for existing instances by @daniwe4 in https://github.com/conceptsandtraining/doil/pull/362
* master uninstall: also remove all doil artifacts with param --not-all by @daniwe4 in https://github.com/conceptsandtraining/doil/pull/363
* master version: update version for update by @daniwe4 in https://github.com/conceptsandtraining/doil/pull/364

**Full Changelog**: https://github.com/conceptsandtraining/doil/compare/20230616...20230815


## 20230616
## What's Changed
* master hotfix:338 skip apt repo check by @daniwe4 in https://github.com/conceptsandtraining/doil/pull/339
* master hotfix:update by @daniwe4 in https://github.com/conceptsandtraining/doil/pull/340

**Full Changelog**: https://github.com/conceptsandtraining/doil/compare/20230615...20230616


## 20230615
## What's Changed
* master hotfix:336 change context for build command by @daniwe4 in https://github.com/conceptsandtraining/doil/pull/337

**Full Changelog**: https://github.com/conceptsandtraining/doil/compare/20230531...20230615


## 20230615_2
## What's Changed
* master hotfix:338 skip apt repo check by @daniwe4 in https://github.com/conceptsandtraining/doil/pull/339

**Full Changelog**: https://github.com/conceptsandtraining/doil/compare/20230615...20230615_2


## 20230531 Performance, Multiuser
Bugfix for https://github.com/conceptsandtraining/doil/releases/tag/20230524


## 20230524
## What's Changed
* master performance: 264 build new instances from a base image; improve multi user usage by @daniwe4 in https://github.com/conceptsandtraining/doil/pull/329

**Full Changelog**: https://github.com/conceptsandtraining/doil/compare/20230329...20230524


## 20230329
## What's Changed
* frh Dockerfiles:321 fix apt calls by @daniwe4 in https://github.com/conceptsandtraining/doil/pull/322
* frh states:323 fix a potentiel empty salt state by @daniwe4 in https://github.com/conceptsandtraining/doil/pull/324

**Full Changelog**: https://github.com/conceptsandtraining/doil/compare/20230324...20230329

## 20230324
## What's Changed
* frh states:319 remove artifact from base state by @daniwe4 in https://github.com/conceptsandtraining/doil/pull/320

**Full Changelog**: https://github.com/conceptsandtraining/doil/compare/20230323...20230324

## 20230323 -  Feature Release Hotfix 3
## What's Changed
* Feature release hotfixes by @daniwe4 in https://github.com/conceptsandtraining/doil/pull/318


**Full Changelog**: https://github.com/conceptsandtraining/doil/compare/20230308...20230323

## 20230308 Feature Release Hotfix 2
Fixes a bug that caused no new branches to be displayed after a repo update.

## 20230223 Feature Release Hotfix 1
Sometimes there are issues at the Dockerfile if 'apt-get update' runs as one liner. Move it before 'apt-get install'.
Fix composer call for composer version lower then 2.2.


## 20230207 Feature Release
### This release will implement most feature requests from users.

The following features have been implemented:

- xDebug can be switched on/off
- Roundcube password freely selectable (during installation and via a state)
- Roundcube settings persist across restarts
- max_execution_time is now set to 3600 seconds by default
- the update script has been implemented again
- doil create log files again (/var/log/doil/)
- nano Editor in all newly created instances
- php*.*-apcu is now installed by default
- various doil commands got a --prune parameter
- various doil commands got a --all parameter
- CLI commands can be routed directly to the instance via doil
- PHP 8.1 is supported
- PHP 7.0 and PHP 7.1 have been removed
- start and stop all instances with one command
- improved salt key handling

## 20221110 PHP-Release Hotfixes 1
### Add requirement checks:
- free ports 80/443
- ssh folder exists
- is user in doil group
### Allow composer to run as root.
### Readme file adjustments.
### Adjust php states.
### Fix composer issue.
### Fix error on salt:restart.

## 20221110

* reorganize folder structure
* refactored commands, using php symfony console as base system
* add php unit tests
* change the way commands are called on cli (see [README.md](https://github.com/conceptsandtraining/doil#doil---create-ilias-development-environments-with-docker-and-ilias))
* add requirements checks for the setup
* update README.md
* remove Update.sh for this version
* doil pack:import can also import doil exports from older doil versions
* fixed a lot of stability bugs

## 20220727

* fixed several bugs regarding salt and proxy integration
* refactored log management
* saltified more scripts
* simplified more scripts

## 20220602

* new [version and contributing policies](.github/CONTRIBUTING.md)
* added transparent [testing protocols](.github/TESTING.md)
* fixed several bugs regarding salt and proxy integration
* implemented mail service system (see [README.md](https://github.com/conceptsandtraining/doil#mail-server))
* implemented better update and install mechanism
* added fallback for `-r` to `-gr` when checking for repositories
* refactored a lot of code
* Even more bulletproofed windows integration
* fixed a lot of stability bugs

## 1.4.4

* Bulletproofed windows integration
* implemented better volume handling
* increased speed for `doil create` by using predefined container
* fixed several salt stack issues
* implemented `-y` flag for `doil delete`
* fixed key check
* updated password generation
* removed `-t` flag for docker exec functions
* fixed cron service start after `doil up`
* updated ilias config with webservices

## 1.4.3

* Fixed port problem in minion services

## 1.4.2

* Added compatibility to Windows and WSL with ubuntu
* Implemented improvements to `doil pack`

## 1.4.1

* Fixed small issues with permissions

## 1.4

* Implemented globla user support
* Added `doil system:proxy host` to change the internal host
* Added `doil instances:processstatus` with `doil ps` as alias
* Added `doil system:user` as user managment
* Added `doil system:salt states` to list the available states
* Implemented lessc in container
* Fixed several states for debian 11
* Fixed Java-Server
* Fixed Cron-Server

## 1.3

* implemented the dotfiles .bashrc, .vimrc, and .gitconfig for more
  comfort on the console
* introduced `doil instances:apply`
* introduced `doil pack`
* fixed problem with deprecated docker images
* fixed several permission problems
* fixed the http_path problem
* made proxy and salt server more solid and moved their commands to
  the system command

## 1.2.1

* Increased timeout of nginx
* moved adminer to docroot and out of the way of the unit tests
* implemented missing PHP packages
* `doil rm` now removes the salt key

## 1.2

* Added proxy server as replacement for the `/etc/hosts` hacks
* removed `doil repair` and `doil update` due to misfunction

### Backwardcompatibility from doil 1.1

Due to technical restictions we can't provide a backwardcompatibility for
the handling of the addresses within instances created by doil. Though it
is still possibile to use instances created with older versions of doil
by editing the `docker-compose.yml` in your project root folder:

Add following lines to the network section of the service:

```
- doil_proxy
- default
```

so that it looks like this:

```
version: "3.5"
services:
  $instance:
    build:
      context: .
      dockerfile: Dockerfile
    image: doil/$instance:stable
    container_name: $instance
    hostname: $instance
    domainname: local
    volumes:
      [...]
    environment:
      [...]
    networks:
      - main_saltnet
      - doil_proxy
      - default
```

At the end of the file add following lines to the network section

```
doil_proxy:
  external: true
```

so that it lookes like this:

```
networks:
  doil_proxy:
    external: true
  main_saltnet:
    external: true
```

After `doil up` your instance will be available at `http://doil/$instance`

### Backwardcompatibility prior doil 1.1

* remove _web
* add hostname (same as container-name)
* add doil_proxy network to main container (see above)

## 1.1

* Added PHP 8.0 suppot
* Added adminer for easy MySQL Access from the browser
* Fixed several composer issues
* Added auto installer for ILIAS >= 7
* Implemented possibility to update php, apache and mysql configs
* Added SSH Key to access private github repositories
* Set `doil update` and `doil repair` to deprecated
* Added aliases `doil rm` and `doil ls`

## 1.0.3

* Fixed occasions where the salt master couldn't communicate due to the
  docker init system and salt
* Fixed error in `doil delete` where it couldn't find the docker image to
  delete
* Fixed zombie process spawning
* Fixed version and build id
* Moved changelog to separate file
* Fixed typos
* repo:add now behaves like expected

## 1.0.2

* Made the salt master and minion comunication more solid
* Fixed minor issues

## 1.0.1

* Fixed a bug in linux templates where the port 80 is blocked so no machine
  could be started
* Added update script
* Changed readme (thanks @Rillke)