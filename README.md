# doil - Create ILIAS Development Environments with Docker and ILIAS

**doil** provides you with a simple way to create and manage development and
testing environments for ILIAS. It will create and provision a docker container
according to your requirements, pull the ILIAS version you want to use and even
install it if possible.

## Installation

1. download and unpack the [latest release](https://github.com/conceptsandtraining/doil/releases)
1. cd into the unpacked directory
1. if you run doil on a remote host ensure to change the host name in `setup/conf/doil.conf` to your host name
1. execute `sudo ./setup/install.sh` in order to install **doil**
1. you can remove the downloaded folder afterwards
1. check `doil help` for available commands and further instructions

## Update (currently not available)
The update command will have a comeback in the following releases.  

Because **doil** now uses PHP after the conversion, we recommend completely removing an already installed
**doil** from the system. This includes already installed instances. After that, you can proceed to the
Installation section.

Removal Tips:

* `docker ps -a` shows all containers
* `docker rm <container_id>` removes container by id (ensure to delete all doil instances)
* `docker images` shows all images
* `docker rmi <image_id>` remove image by id (ensure to delete all doil images)
* `docker volume ls` shows all volumes
* `docker volume rm <volume_name>` remove volume by name (ensure to delete mail, proxy and salt)
* `docker network prune` removes all networks without dependencies
* `sudo rm -rf /etc/doil /usr/local/lib/doil /usr/local/share/doil /usr/local/bin/doil ~/.doil`

## Dependencies

**doil** tries to use as little 3rd party software on the host system as possible,
however **doil** needs [Docker](https://www.docker.com/) in order to work:

* docker version >= 19.03
* docker-compose version >= 1.25.0 (ensure that root has access too)
* php version => 7.4
* php*.*-zip
* php*.*-dom
* composer version = depending on installed php version
* git

Additional dependencies, but these are installed automatically during setup.

* symfony/console
* symfony/filesystem
* symfony/process
* pimple
* ext/posix
* ext/zip
* ext-openssl

## Usage

### Quick Start

**Before starting make sure that you have set up your [docker usergroup correctly](https://docs.docker.com/engine/install/linux-postinstall/)**

After you installed doil the basic system is ready to go. To get an instance of
ILIAS running you simply need to do following steps:

1. Head to a folder where you want to store your project. Usually `~/Projects`
1. Enter following command: `doil create -n -e ilias -r ilias -b release_7 -p 7.4 -u`

Don't worry, this will take a while. It creates and instance of ILIAS named `ilias`
in your location from the repository `ilias` (see `doil repo:list`) with the known
branch `release_7` and the PHP version `7.4`.

After this job is finished you can start your instance with `doil up ilias` and head
to `http://doil/ilias/` to see your fresh ILIAS installation.

### Help

Each command for doil comes with its own help. If you struggle to use a command,
just add `-h` or `--help` to display the according help page. For example:
`doil instances:create --help`. Use a simple `doil` if you have no idea where to
start.

### Instances

An *instance* is one environment for an installation of ILIAS. The purpose of
**doil** is to make the management of these instances as simple as possible.
The following commands are available:

* `doil create` (alias for `doil instances:create`) creates a new instance in
  the current working directory
* `doil up <instance_name>` starts an instance that you have created before
* `doil path` prints the path to the location of the instance
* `doil ls` lists all available instances
* `doil login <instance_name>` logs you into the container running the instance
* `doil down <instance_name>` stops an instance to free the resources it needs
* `doil delete <instance_name>` deletes an instance you do not need anymore
* `doil status` lists the current running doil instances

See `doil instances:<command> --help` for more information

### Repository

**doil** can use different ILIAS repositories to create instances. Per default,
the [repository of the ILIAS society](https://github.com/ILIAS-eLearning/ILIAS)
will be used to pull the ILIAS code. If you want to use another repository to get
the ILIAS code, you can use commands from `doil repo` to add and manage these
other repositories:

* `doil repo:add` will add a repository to the configuration
* `doil repo:update <repo_name>` will download the repo to **doil**'s local cache or update
  it if it is already downloaded
* `doil instances:create --repo REPO_NAME` will use the repo to create a new
   instance
* `doil repo:delete <repo_name>` - removes a repository
* `doil repo:list` - lists currently registered repositories

See `doil repo:<command> --help` for more information

### Global User Support

If you are running `doil` on a system with multiple users you can manage your
repositories and instances globally for all user. For that we implemented several
helper and flags.

#### Adding user to doil

The user who installed doil on the machine is already registered at doil. To add
another user simply use `doil system:user add <username>`. You can manage the users
with following commands:

* `doil user:add <username>` adds a user
* `doil user:delete <username>` deletes a user
* `doil user:list` lists the available users

See `doil user:<command> --help` for more information

#### The `--global` flag

Most commands in doil come with a `--global` flag. For instance if you created an
ILIAS instance with `doil create --global` the instance will then be available to
all registered users. You can start the instance with `doil up <instance> --global`.

If you want to create an instance with a global repository you have to use the flag
`-u|--use-global-repo`, e.g, `doil create -r ilias -u`

Following commands come with the `--global` flag:

**`doil instances`**
* `doil instances:create`
* `doil instances:up`
* `doil instances:down`
* `doil instances:delete`
* `doil instances:apply`
* `doil instances:path`
* `doil instances:login`

**`doil repo`**
* `doil repo:add`
* `doil repo:delete`
* `doil repo:update`

**doil pack**
* `doil pack:import`
* `doil pack:export`

You can also create global instances with private repositories and vice versa.

### Pack

**doil** lets you transfer the data of one installation of ILIAS ot another. Instances
build with doil (instances from version >=1.1) are able to be exported.

* `doil pack:export` exports an instance
* `doil pack:import` imports an instance

See `doil pack:<command> --help` for more information

### Quietmode and Logs (currently not available)

Most of the commands come with a `--quiet` flag to omit the log messages.
However these logs are not lost, they are stored in `/var/log/doil.log`. You may
want to add a rotation to this logfile.

## Known Restrictions

* **doil** was developed and tested on debian and ubuntu systems. It might run
  on other linux based platforms but there is no guarantee

### doil on MacOS (currently not tested)

* due to network restrictions on MacOS **doil** can only operate run one instance
  at once. Though it's possible to create as many environments as you want

### doil on Windows (currently not available)

* **doil** works on Windows with the WSL2 and Ubuntu 20.10 enabled. Due to network restrictions you
  need to change the host to `localhost` via the doil proxy settings:
  `doil system:proxy host localhost`

## Known Problems

### 404 after doil up

Sometimes it is possible that the proxy server doesn't accept the configuration. This results
in a 404 when heading to your instance after using `doil up`. To fix this you just need to restart
the proxy server with `doil system:proxy restart`. If the 404 still occurs restart your instance
with `doil down` and `doil up`.

### The key not ready loop

While creating an instance or using `doil apply` it is possible that there will be a "Key not ready"
loop. This loop tries to find a certain key in the salt main server. To fix this issue let the loop
run and open a new terminal and do following steps:

* `doil system:salt prune`
* `doil system:salt restart`
* `doil down <instance_name>`
* `doil up <instance_name>`

Usually the loop will then resolve itself and the creation or apply process will continue. If the loop
continues then there might be a problem with the public key of the salt main server. To fix this do
following steps:

* `doil login <instance_name>`
* `rm /var/lib/salt/pki/minion/minion_master.pub`
* `exit`
* `doil down <instance_name>`
* `doil up <instance_name>`

## Background, Troubleshooting and Development

**doil** uses [SaltStack](https://docs.saltproject.io/en/latest/) to provision and maintain
the instances. [Docker](https://www.docker.com/) is only used as a light weight
and widely available VM-like technology to run sufficiently isolated linux
environments. SaltStack uses an architecture where one master acts as a central
control server. **doil** runs this master in a dedicated container. The instances
then are deployed into separate containers as minions that are controlled and
provisioned by the master. Required folders are mounted in the users filesystem
via Dockers volumes and can be accessed from the host system.

### System

**doil** comes with some helpers which are usefull if you want to hack on **doil**:

* `doil system:uninstall` will remove doil from your system
* `doil -V|--version` displays the version
* `doil` displays the main help page


### SaltStack

To be able to dive deeper into the inner workings of **doil** or customize it
to fit your workflow or requirements, **doil** provides commands to tamper with
the saltstack in the background. These commands will not be required by ordinary
users, so make sure to understand what you are doing.

* `doil salt:login` logs the user into the main salt server
* `doil salt:prune` prunes the main salt server
* `doil salt:start` starts the salt main server
* `doil salt:stop` stops the salt main server
* `doil salt:restart` restarts the salt main server
* `doil salt:states` to list the available states

See `doil salt:<command> --help` for more information

### Proxy Server

To be able to dive deeper into the inner workings of **doil** or customize it
to fit your workflow or requirements, **doil** provides commands to tamper with
the proxy in the background. These commands will not be required by ordinary
users, so make sure to understand what you are doing.

* `doil proxy:login` logs the user into the proxy server
* `doil proxy:prune` removes the configuration of the proxy server
* `doil proxy:start` starts the proxy server
* `doil proxy:stop` stops the proxy server
* `doil proxy:restart` restarts the proxy server
* `doil proxy:reload` reloads the configuration

See `doil proxy:<command> --help` for more information

### Mail Server

The mailserver is available at `http://doil/mails` with following
login data:

* User: www-data
* Password: ilias

Every minion sends all E-Mails to this mailserver.

To be able to dive deeper into the inner workings of **doil** or customize it
to fit your workflow or requirements, **doil** provides commands to tamper with
the mailserver in the background. These commands will not be required by ordinary
users, so make sure to understand what you are doing.

* `doil mail:login` logs the user into the mail server
* `doil mail:start` starts the mail server
* `doil mail:stop` stops the mail server
* `doil mail:restart` restarts the mail server

## Contributions and Support

Contributions to doil are very welcome!

* Have a look into the [Contributor's Guide](.github/CONTRIBUTING.md) before
  you start.
* If you face any issues or want to suggest a feature or improvement, open an
  [issue](https://github.com/conceptsandtraining/doil/discussions").
* Make sure to understand that this is a voluntary offer which requires time,
  passion and effort and does not guarantee anything to anyone. Be gentle.

If doil saved your precious time and brain power, please consider supporting
**doil**:

* Buy Laura (initial creator) a coffee and tell her about your doil experiences if you meet her
  somewhere.
* Star the project and share it. If you blog, please share your experience of
  using this software.
* Look into [CaT's products and services](https://www.concepts-and-training.de)
  and consider to place an order or hire us.
* Reach out to [Daniel](daniel.weise@concepts-and-training.de) and [Richard](richard.klees@concepts-and-training.de)
  if you have requirements, ideas or questions that you don't want to discuss
  publicly.
* Reach out to [Richard](richard.klees@concepts-and-training.de) if you need
  more support than we can offer for free or want to get involved with **doil**
  in other ways.