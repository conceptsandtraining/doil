#!/bin/bash

# We create a network here which is used by all the ilias containers. So
# every container can communicate to each other, also there will be a
# global database
docker network create -d bridge dc-ilias-network
echo "Network with the name dc-ilias-network created. You can use it now in your configs."
