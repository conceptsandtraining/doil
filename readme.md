# ILIAS Tool Docker

This tool creates and manages multiple docker container with ILIAS and comes with several tools to help manage everything. It is able to download ILIAS and TMS (with all its plugins and skins).

## MySQL and phpMyAdmin

There is one docker container which setups mysql und phpMyAdmin. After startup phpMyAdmin will be available at localhost:8000. The MySQL-Server runs on the port 3306.

## Initial Setup

1. In order to get these tools up and running you first need to check your docker permissions. For that simply execute `/tools/fix-docker-permissions.sh`.
2. Create the internal docker network with the script `/tools/create-network.sh`
3. Start the MySQL and phpMyAdmin container with the script `/dc-mysql/up.sh`

The MySQL container need to be startet after every reboot of your system.

## Usage

1. Execute the script `/tools/container.sh` and follow the steps.
2. Login to your new container with `/$new-container/login.sh` and execute `/var/www/composer-install.sh`

You then can reach your ILIAS installation at `http://localhost:$your-port`

## Included tools

This toolbox comes with three handy tools. Every generated container provides several scripts which will help you to manage the container itself.

### up.sh

Starts a container

### down.sh

Stops a container

### login.sh

Logs you into the current container if it is running.

## General information

### Finding the database server ip

With the order `docker network inspect dc-ilias-network` you will get an output of all the current running container within the docker network. The database server is named `dcmysql_db_1`. A sample json output looks like that:

```json
"238b663923caebd7c8d9a497ab19e63b2c5489baddcea2a646939c860c9f308b": {
    "Name": "dcmysql_db_1",
    "EndpointID": "7da4fbf657b8997a5ac50e94b0de35860a8ef7d4e483b0875442b2ae050dc66e",
    "MacAddress": "02:42:ac:12:00:02",
    "IPv4Address": "172.18.0.2/16",
    "IPv6Address": ""
},
```

Therefore the IP is 172.18.0.2

## Outlook

* automatic execution of composer install after container creation
* automatic installation of ILIAS and TMS
* add dummy data to blank installations
* sync client data
