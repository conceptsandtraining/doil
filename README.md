# doil - Create ILIAS Development Environments with Docker and ILIAS

**doil** provides you with a simple way to create and manage development and
testing environments for ILIAS. It will create and provision a docker container
according to your requirements, pull the ILIAS version you want to use and even
install it if possible. Also, **doil** provides you with a mail server wich collects 
all mails from your instances, so you can test the ILIAS emailing.

## Installation

1. download and unpack the [latest release](https://github.com/conceptsandtraining/doil/releases)
1. cd into the unpacked directory
1. if you run doil on a remote host ensure to change the host name in `setup/conf/doil.conf` to your host name
1. adjust your mail password in `setup/conf/doil.conf`
1. if you run global instances make sure to adjust 'global_instances_path' in `setup/conf/doil.conf` to specify
   where to place them, default is '/srv/instances'. Attention, paths with 'home' are not allowed here.
1. execute `sudo ./setup/install.sh` in order to install **doil**
1. you can remove the downloaded folder afterwards
1. check `doil help` for available commands and further instructions

## Update
 
If you use a **doil** version older than 20221110, we recommend completely removing an already installed
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
* `sudo rm -rf /etc/doil /usr/local/lib/doil /usr/local/share/doil /usr/local/bin/doil ~/.doil /var/log/doil`
* remove the instances folders or if you placed all instances in one folder remove the whole folder

Otherwise, use the update script.

1. checkout the newest master branch or copy and extract the zip
2. cd into the unpacked directory
3. if you run global instances make sure to adjust 'global_instances_path' in `setup/conf/doil.conf` to specify 
where to place them, default is '/srv/instances'. Attention, paths with 'home' are not allowed here. The update
will move all global instances to the set path.
4. execute sudo ./setup/update.sh in order to update **doil**
5. you can remove the downloaded folder afterward


## Dependencies

**doil** tries to use as little 3rd party software on the host system as possible,
however **doil** needs [Docker](https://www.docker.com/) in order to work:

* docker (follow [this](https://docs.docker.com/engine/install/) instructions depending on your os to install docker), if you have installed docker by your package manager ensure that **docker-buildx-plugin** and **docker-compose-plugin** are available and installed and also executable by your user.
* git
* .ssh folder in your home directory. **doil** will mount it into the container. **doil** needs this to have access to any private git repositories that may be used. 

Additional dependencies, but these are installed automatically during setup.

* php version => 7.4
* php*.*-zip
* php*.*-dom
* composer version = depending on installed php version
* symfony/console
* symfony/filesystem
* symfony/process
* pimple
* ext/posix
* ext/zip
* ext-openssl
* psr/log
* monolog/monolog

The easiest way to fulfill the dependencies is Ubuntu 22.01, but it should also be possible with any other Linux installation.

## Usage

### Quick Start

**Before starting make sure that you have set up your [docker usergroup correctly](https://docs.docker.com/engine/install/linux-postinstall/)**

After you installed doil the basic system is ready to go. To get an instance of
ILIAS running you simply need to do following steps:

1. Head to a folder where you want to store your project. Usually `~/Projects`
1. Enter following command: `doil create -e ilias7 -r ilias -b release_7 -p 7.4 -u`

Don't worry, this will take a while. It creates and instance of ILIAS named `ilias7`
in your location from the repository `ilias` (see `doil repo:list`) with the known
branch `release_7` and the PHP version `7.4`.
Be aware, there is no check wich php version matches on which ILIAS version.

After this job is finished you can start your instance with `doil up ilias7` and head
to `http://doil/ilias7/` to see your fresh ILIAS installation.

You can also get a quick overview on running **doil** instances by navigating with your
browser to 'http://doil'. If you have changed the host variable in the doil.conf file you
have to call 'http://<host_value>'.

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
* `doil exec <instance_name> <cmd>` executes a bash command inside the instance
* `doil sut` (alias for `doil instances:set-update-token`) Sets an update token as an environment variable. More Info [here](#update-token-handling) 

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

* `doil user:add <username>` adds a user (needs sudo privileges)
* `doil user:delete <username>` deletes a user (needs sudo privileges)
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
* `doil instances:exec`
* `doil instances:csp`
* `doil instances:set-update-token`

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

To start `doil:pack export` via cronjob you need two additional parameters. 
The first parameter (-T or --no-term) is attached to the **doil** commando. 
It ensures that docker can run without a terminal.
The second parameter (-c or --cron) is required for the `pack:export` command. 
It ensures that the console command does not open an additional terminal. 
The complete call then looks like this:

```bash
doil -T pack:export -c <instance_name> [-g]
```

### Quietmode and Logs

Most of the commands come with a `--quiet` flag to omit the log messages.
However, these logs are not lost, they are stored in `/var/log/doil/doil.log` and in `/var/log/doil/salt.log`. You may
want to add a rotation to this logfile.

## Known Restrictions

* **doil** was developed and tested on debian and ubuntu systems. It might run
  on other linux based platforms but there is no guarantee

### doil on MacOS (currently not tested)

* due to network restrictions on MacOS **doil** can only operate run one instance
  at once. Though it's possible to create as many environments as you want

### doil on Windows (no longer supported)

* We only use **doil** on Linux systems in our company. If you want to run **doil** under Windows, please
  send an email to daniel.weise@concepts-and-training.de and we will decide as a team whether to resume support.

## Known Problems

### Doil on Mac Ubuntu 22.01 Server (VMWare Fusion)
There may be a problem with the ~/.docker directory. It may happen that after a reboot the file permissions and the owner of the folder have to be adjusted again. If this is the case for you, you can also consider creating a startup script that automatically adjusts this folder every time the system starts.

### Proxy Server (Minions did not return) during install/update
If the proxy server reports 'Minion did not return' during the install/update process, please abort the process and start it again.

### 404 after doil up

Sometimes it is possible that the proxy server doesn't accept the configuration. This results
in a 404 when heading to your instance after using `doil up`. To fix this you just need to restart
the proxy server with `doil proxy:restart`. If the 404 still occurs restart your instance
with `doil down` and `doil up`.

### The key not ready loop

While creating an instance or using `doil apply` it is possible that there will be a "Key not ready"
loop. This loop tries to find a certain key in the salt main server. To fix this issue let the loop
run and open a new terminal and do following steps:

* `doil salt:prune`
* `doil salt:restart`
* `doil down <instance_name>`
* `doil up <instance_name>`

Usually the loop will then resolve itself and the creation or apply process will continue. If the loop
continues then there might be a problem with the public key of the salt main server. To fix this do
following steps:

* `doil login <instance_name>`
* `rm /etc/salt/pki/minion/minion_master.pub`
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

**doil** comes with some helpers which are useful if you want to hack on **doil**:

* `doil -V|--version` displays the version
* `doil` displays the main help page

Also, there is a script to uninstall **doil** in the doil repo. If you have already deleted
the folder easily clone it again from [doil](https://github.com/conceptsandtraining/doil).

Cd into the cloned folder and execute the script.

`sudo ./setup/uninstall.sh`

The script will ask you if you want to remove **doil** completely from your system or if you
want to keep your instances, images ...


### SaltStack

To be able to dive deeper into the inner workings of **doil** or customize it
to fit your workflow or requirements, **doil** provides commands to tamper with
the saltstack in the background. These commands will not be required by ordinary
users, so make sure to understand what you are doing.

* `doil salt:login` logs the user into the main salt server
* `doil salt:prune` prunes the main salt server
* `doil salt:up` starts the salt main server
* `doil salt:down` stops the salt main server
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
* `doil proxy:up` starts the proxy server
* `doil proxy:down` stops the proxy server
* `doil proxy:restart` restarts the proxy server
* `doil proxy:reload` reloads the configuration

See `doil proxy:<command> --help` for more information

#### Https
There is the state 'proxy-enable-https' to make the proxy accessible via https.
This is done by certbot.
In order for this state to run successfully, it is important that the proxy is already accessible from the Internet and the DNS entries are set.  
To execute the state you have to log in to the salt master using `doil salt:login`. The following command is then executed there:
```bash
 salt 'doil.proxy' state.highstate saltenv=proxy-enable-https pillar='{"email": "<your_email>", "domain": "<your_domain>"}'
```
If the state has run successfully, the current status of the proxy still needs to be committed. To do this, leave the
salt master again with `ctrl-d` and execute the following command:
```bash
docker commit doil_proxy doil_proxy:stable
```
The state also sets up a cron job that regularly renews the certificates.  

After that please ensure to run `doil apply <instance_name> enable-https` on each doil ILIAS instance,
so https take effect in ILIAS.

It is also important to set the value 'http_proxy' in setup/conf/doil.conf to true before each update.
This ensures that newly created instances are always created with https.

### Mail Server

The mailserver is available at `http://doil/mails` with following
login data:

* User: www-data
* Password: ilias

You can change the password in the **doil** config file `setup/conf/doil.conf`.
Before installing **doil** change the default password to your password.
If doil is already installed you can change the password by `doil mail:change-password <password>`.
Please ensure you also update the password in your actual installed
**doil** config `/etc/doil/doil.conf`, so you don't have to set the passwort again after a doil update.


Every minion sends all E-Mails to this mailserver.

To be able to dive deeper into the inner workings of **doil** or customize it
to fit your workflow or requirements, **doil** provides commands to tamper with
the mailserver in the background. These commands will not be required by ordinary
users, so make sure to understand what you are doing.

* `doil mail:change-password` changes the default password for roundcube
* `doil mail:login` logs the user into the mail server
* `doil mail:up` starts the mail server
* `doil mail:down` stops the mail server
* `doil mail:restart` restarts the mail server

### Keycloak Server

The Keycloak server is an identity provider that allows you to log in to all 
ILIAS instances managed by **doil** with one password.  
This requires some settings in the doil.conf file. 'doil.conf' can be found 
under setup/conf/doil.conf. The adjustments must be made before an update/install.

The following settings are available:

* `enable_keycloak=[true/false]`  decides whether keycloak is installed during 
an update/install [default:false]
* `keycloak_hostname=http://doil/keycloak` keycloak url, please pay attention to https/http
* `keycloak_new_admin_password=12345` admin password
* `keycloak_old_admin_password=admin` If the password is changed during an update, the old 
password must be entered here. Please make sure to adjust it after the update. For the first
installation this has to be 'admin'.
* `keycloak_db_username=admin` database user name
* `keycloak_db_password=admin` database user password

If you use keycloak, the salt state enable-saml must be called for existing ILIAS instances.
This is done using the 'doil apply <instance_name>' command.  
Newly created instances check whether keycloak is enabled and set up the instance directly.

In order to use SAML for an Ilias instance, it must be ensured that a user is created in the
ILIAS interface and a user in the Keycloak interface.

#### Create a user in Keycloak
* select tab 'users' from left menu
* click 'Add user'
* enter a Username
* enter an Email
* click 'Create'

#### Cretae a user in ILIAS
* select tab 'Administration' from left menu
* select 'Users and Roles'
* select 'User Management'
* click 'Add User'
* fill in the required fields (username must be the same as in keycloak)
* set 'External Account' to the same email as in keycloak

To be able to dive deeper into the inner workings of **doil** or customize it
to fit your workflow or requirements, **doil** provides commands to tamper with
the keycloak in the background. These commands will not be required by ordinary
users, so make sure to understand what you are doing.

* `doil keycloak:login` logs the user into the keycloak server
* `doil keycloak:up` starts the keycloak server
* `doil keycloak:down` stops the keycloak server
* `doil keycloak:restart` restarts the keycloak server

See `doil keycloak:<command> --help` for more information

### xdedug

**doil** provides two options to enable xdebug for the given instance.  

Option 1: An instance can be created with the '-x' flag, or alternatively 
in interactive mode you will be asked to install xdebug.  
On the command line it could look like this:  
* `doil create -e ilias7 -r ilias -b release_7 -p 7.4 -u -x`

Option 2: You can apply a state to an already existing instance.  
To activate xdebug use the following command:

* `doil apply <instance_name> enable-xdebug`

Alternatively, you can type `doil apply <instance_name>` and select
'enable-xdebug' from the list.

You can turn off xdebug again in the same way:

* `doil apply <instance_name> disable-xdebug`

xdebug listens to port 9000 when activated. Now the client has to be set up. 
Unfortunately, I can only present the configuration of PHP-Storm here as an example.
But it should work similarly for other editors.

#### Necessary PHP-Storm plugins:

* PHP Docker
* PHP Remote

#### PHP-Storm settings

* it is best to open the doil instance root directory in PHP-Storm.
* under Settings->PHP->CLI Interpreter: add a new interpreter (on the 3 dots and then in the pop-up on +)
* select "From Docker, Vagrant..." and then select "Docker Compose".
* if you already have the doil instance root open in PHP-Storm, it automatically selects the docker-compose.yml
* select the doil instance name under Service (e.g. ilias7) and click "OK".
* click on the reload icon under General PHP executable and the warnings should disappear. Then click 'OK' to close the pop-ups.
* click "Apply" and "OK"
* set a breakpoint somewhere that should be reached
* click on the "Listen for PHP Debug Connections" in the upper right corner

#### Browser settings

* install 'Xdebug helper' as a browser extension
* activate the little bug in the address bar

Now, reload the ILIAS page to debug. PHP-Storm should inform you about an incomming debug connection.

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

### Prevent Super Globals Replacement
Since ILIAS version 8 it is necessary to set the setting 'prevent_super_global_replacement = 1' in the
client.ini.php. **doil** offers a state for this.
```bash
doil apply <instance_name> prevent-super-global-replacement
```
As of **doil** version 20241113, **doil** applies this state independently to newly created instances.

### Update Token Handling
Doil instances can be updated via token. There is an entry for this in setup/doil.conf. By default, this entry
is set to 'false' and thus prevents the feature from being activated. To activate the feature once, the value 
must be adjusted and then a doil update must be run.  
Once the feature has been activated, the token can be updated subsequently using the following command:
```bash
doil sut -t <token>
```
If the feature is active and the token is set up, an update command can be sent via the URL
```bash
http://doil/<instance>/.update_hook.php?base_ref=<target_branch>
```
If the currently checked out branch equals to target_branch the branch is updated. A 'composer install' and a
'php setup update' are then carried out. It is important that the Http header contains the field 'Authorization:<token>'
and the url has a parameter 'base_ref'. 'base_ref' in this case is the target branch. A curl command might look like this.
```bash
curl -H "Authorization:MyToken" http://doil/<instance>/.update_hook.php?base_ref=master
```