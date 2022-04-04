# Changelog

## 20220322

* new [version and contributing policies](.github/CONTRIBUTING.md)
* added transparent [testing protocols](.github/TESTING.md)
* fixed several bugs regarding salt and proxy integration
* implemented mail service system
* implemented better update and install mechanism
* added fallback for `-r` to `-gr` when checking for repositories
* refactored a lot of code
* Even more bulletproofed windows integration

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