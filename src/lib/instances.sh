#!/bin/bash
WHOAMI=$(whoami)
INSTANCES="${HOME}/.doil/"

echo -e "Current registered instances for $WHOAMI:"
ls $INSTANCES
