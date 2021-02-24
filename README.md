# ILIAS Tool Docker

This tool creates and manages multiple docker container with ILIAS and comes with several tools to help manage everything. It is able to download ILIAS and other ILIAS related software like cate.

## Setup

1. Download and unpack this repository wherever you want
2. Execute `sudo ./install.sh` in order to install doil (you can remove the downloaded folder afterwards)
3. Check `doil help` for available commands and further instructions

## Dependencies

doil tries to use as little 3rd party software as possible. However doil needs definitly the docker software in order to function:

* docker version >= 19.03
* docker-compose version >= 1.25.0

## Usage

### Help

Each command for doil comes with its own help. If you struggle to use a command, just add `-h` or `--help` to display the help page. For example: `doil instances:create --help`.

### Instances

To create, delete and manage doil instances these commands are available:

* `doil instances:create` - Creates an instance
* `doil instances:delete` - Deletes an instance
* `doil instances:up` - Starts an instance
* `doil instances:down` - Stops an instance
* `doil instances:login` - Loggs the user into the container
* `doil instances:list` - Lists all currently created instances
* `doil instances:cd` - Switches the active directory to the instances one
* `doil instances:repair` - Tries to repair the instance

#### Backward Compatibility and Aliases

In old versions of doil it was possible to use shorter command chains to manage the instances. These commands are still available and are basically aliases for the commands above:

* `doil create` translates to `doil instances:create`
* `doil delete` translates to `doil instances:delete`
* `doil up` translates to `doil instances:up`
* `doil down` translates to `doil instances:down`
* `doil login` translates to `doil instances:login`
* `doil cd` translates to `doil instances:cd`

### Repository

doil is able to manage different ILIAS repositories to create instances. If you or your company forked ILIAS to an own repository you still can use it within doil. The steps to add and use a different repository are:

1. `doil repo:add --name $myreponame --repo git@github.com:myorg/ILIAS.git` to add the repository to the configuration whileas $myreponame is a lower case single word to identify the repository (it's basically the same like `git remote add $name $repo`)
2. `doil repo:update $myreponame` to download the repository to the local cache
3. `doil instances:create --repo $myreponame` to use the repository as instance base

#### Commands

* `doil repo:add` - Adds a repository
* `doil repo:remove` - Removes a repository
* `doil repo:list` - Lists currently registered repositories
* `doil repo:update` - Updates the cache of a repository

### Saltstack

To manage the technology stack in the background doil uses the salt technology. Usually these commands are only necessary for a deep dive into the doil technology.

* `doil salt:set` - Sets the repository for the saltstack
* `doil salt:reset` - Resets the saltstack to the buildin saltstack
* `doil salt:update` - Updates the saltstack if you are using a custom saltstack
* `doil salt:login` - Logs the user into the main salt server
* `doil salt:prune` - Prunes the main salt server

### System

The doil system comes with some little helpers which are usefull if you help develop doil:

* `doil system:deinstall`- doil will be removed from your system
* `doil system:prune`- Resets the configurations and cached data of doil
* `doil system:version`- Displays the version
* `doil system:help`- Displays the main help page

#### Aliases

* `doil -v|--version` translates to `doil system:version`
* `doil`, `doil -h|--help` translates to `doil system:help`

## Contributing

Contributions are welcome!

- See [Contributor's Guide](.github/CONTRIBUTING.md "conceptsandtraining/doil contribution guide") before you start.
- If you face any issues or want to suggest a feature/improvement, start a discussion [here](https://github.com/conceptsandtraining/doil/discussions "doil discussions").

### Support This Project

- If doil saved your developer time, please consider sponsoring doil:
  - Buy me a [coffee](https://paypal.me/lauraquellmalz)
  - Buy [premium support](mailto:ilias-dev@concepts-and-training.de)
  - Checkout [our services](http://concepts-and-training.de)
- Please [reach out](mailto:ilias-dev@concepts-and-training.de) if you have any questions regarding sponsoring doil.
- Please star the project and share it. If you blog, please share your experience of using this software.