# ILIAS Tool Docker

This tool creates and manages multiple docker container with ILIAS and comes with several tools to help manage everything. It is able to download ILIAS and other ILIAS related software like cate.

## Setup

1. Download and unpack this repository wherever you want
2. Execute `sudo ./install.sh` in order to install doil (you can remove the downloaded folder afterwards)
3. Check `man doil` or `doil help` for available commands and further instructions

## Dependencies

doil tries to use as little 3rd party software as possible. However doil needs some software from other sources in order to function:

* docker
* docker-compose
* dialog

## Configuration

### Adding more ILIAS repositories

It is possible to add more repositories to the list which doil can use to install ILIAS. After the installation of doil head to `~/.doil/config/`  and edit the file `repos`. Add your git-Repository in this pattern: `$name=$git-repo-url`. Make sure you are using the SSH version of the git repository.

### Adding own saltstack

Simply fork our saltstack (place URL here) and edit or add files you need. After that you can implement this stack into doil by editing the file `~/.doil/config/saltstack` and replace it with the git repository of your saltstack.

## Known problems

1. Sometimes the salt master server cannot apply the states to your instances. This results in non working environments. This happens due to hardware restrictions. If you can see the line `Salt request timed out. The master is not responding. You may need to run your command with --async in order to bypass the congested event bus. With --async, the CLI tool will print the job id (jid) and exit immediately without listening for responses. You can then use salt-run jobs.lookup_jid to look up the results of the job in the job cache later.` in your log then your system ran into that issue. You can try to fix this by deleting unnecessary docker images. See `docker image ls`. You also should check if the `saltmain` network is registered correctly by using `docker network inspect main_saltnet`.