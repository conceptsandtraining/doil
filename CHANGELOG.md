# Changelog

## 1.0.3

* Fixed occasions where the salt master couldn't communicate due to the
  docker init system and salt
* Fixed error in `doil delete` where it couldn't find the docker image to
  delete
* Fixed zombie process spawning
* Fixed version and build id
* Moved changelog to separate file

## 1.0.2

* Made the salt master and minion comunication more solid
* Fixed minor issues

## 1.0.1

* Fixed a bug in linux templates where the port 80 is blocked so no machine
  could be started
* Added update script
* Changed readme (thanks @Rillke)