# doil - Create ILIAS Development Environments with Docker and ILIAS

**doil** provides you with a simple way to create and manage development and
testing environments for ILIAS. It will create and provision a docker container
according to your requirements, pull the ILIAS version you want to use and even
install it if possible.

## Installation

1. download and unpack the [latest release](https://github.com/conceptsandtraining/doil/releases)
1. execute `sudo ./install.sh` in order to install **doil**
1. you can remove the downloaded folder afterwards
1. check `doil help` for available commands and further instructions

## Update

If you alread installed **doil** you can easily update with following steps:

1. download and unpack the [latest release](https://github.com/conceptsandtraining/doil/releases)
1. execute `sudo ./update.sh` in order to update **doil**
1. you can remove the downloaded folder afterwards

## Dependencies

**doil** tries to use as little 3rd party software on the host system as possible.
However **doil** needs [Docker](https://www.docker.com/) in order to work:

* docker version >= 19.03
* docker-compose version >= 1.25.0

## Usage

### Help

Each command for doil comes with its own help. If you struggle to use a command,
just add `-h` or `--help` to display the according help page. For example:
`doil instances:create --help`. Use `doil --help` if you have no idea where too
start.

### Instances

An *instance* is one environment for and installation of ILIAS. The purpose of
**doil** is to make the management of these instances as simple as possible.
The following commands are available:

* `doil create` (alias for `doil instances:create`) creates a new instance in
  the current working directory
* `doil up` starts an instance that you have created before
* `doil cd` switches the current working directoryto the location of the instance
* `doil ls` lists all available instances
* `doil login` logs you into the container running the instance
* `doil down` stops an instance to free the ressources it needs
* `doil rm` deletes an instance you do not need anymore
* look into `doil instances --help` for further commands related to instances

## Known Restrictions

* **doil** was developed and tested on debian and ubuntu systems. It might run
  on other linux based platforms but there is no guarantee
* due to network restrictions on MacOS **doil** can only operate run one instance
  at once. Though it's possible to create as many environments as you want
* **doil** works on Windows with the WSL enabled. We are aware that there might
  be a bug with routing the traffic from WSL to the browser. If you can find a
  solution for this, let us know

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

* Buy Laura a coffee and tell her about your doil experiences if you meet her
  somewhere.
* Star the project and share it. If you blog, please share your experience of
  using this software.
* Look into [CaT's products and services](https://www.concepts-and-training.de)
  and consider to place an order or hire us.
* Reach out to [Laura](laura.herzog@concepts-and-training.de) and [Richard](richard.klees@concepts-and-training.de)
  if you have requirements, ideas or questions that you don't want to discuss
  publicly.
* Reach out to [Richard](richard.klees@concepts-and-training.de) if you need
  more support than we can offer for free or want to get involved with **doil**
  in other ways.

## Background, Troubleshooting and Development

**doil** uses [SaltStack](https://docs.saltproject.io/en/latest/) to provision and maintain
the instances. [Docker](https://www.docker.com/) is only used as a light weight
and widely available VM-like technology to run sufficiently isolated linux
environments. SaltStack uses an architecture where one master acts as a central
control server. **doil** runs this master in a dedicated container. The instances
then are deployed into separate containers as minions that are controlled and
provisioned by the master. Required folders are mounted in the users filesystem
via Dockers volumes and can be accessed from the host system.

If you have the suspicion that something went wrong here or you accidentally
messed up an instance, try `doil instances:repair` to make **doil** attempt to
fix the problem.

### Repository

**doil** can use different ILIAS repositories to create instances. Per default,
the [repository of the ILIAS society](https://github.com/ILIAS-eLearning/ILIAS)
will be used to pull the ILIAS code. If you want to use another repository to get
the ILIAS code, you can use commands from `doil repo` to add and manage these
other repositories:

* `doil repo:add` will add a repository to the configuration
* `doil repo:update` will download the repo to **doil**'s local cache or update
  it if it is already downloaded
* `doil instances:create --repo REPO_NAME` will use the repo to create a new
   instance
* `doil repo:remove` - removes a repository
* `doil repo:list` - lists currently registered repositories

### System

**doil** comes with some helpers which are usefull if you want to hack on **doil**:

* `doil system:deinstall` will be remove doil from your system
* `doil system:version` displays the version
* `doil system:help` displays the main help page

### SaltStack

To be able to dive deeper into the inner workings of **doil** or customize it
to fit your workflow or requirements, **doil** provides commands to tamper with
the saltstack in the background. These commands will not be required by ordinary
users, so make sure to understand what you are doing.

* `doil system:salt restart` restarts the salt main server
* `doil system:salt login` logs the user into the main salt server
* `doil system:salt prune` prunes the main salt server

### Proxy Server

To be able to dive deeper into the inner workings of **doil** or customize it
to fit your workflow or requirements, **doil** provides commands to tamper with
the proxy in the background. These commands will not be required by ordinary
users, so make sure to understand what you are doing.

* `doil system:proxy restart` restarts the proxy server
* `doil system:proxy login` logs the user into the proxy server
* `doil system:proxy prune` prunes the proxy server