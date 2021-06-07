# Changelog

## 1.2

* Added proxy server as replacement for the `/etc/hosts` hacks

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