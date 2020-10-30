#!/bin/bash
WHOAMI=$(whoami)
INSTANCES="/home/$WHOAMI/.doil/"

echo -e "Current registered instances for $WHOAMI:"
ls $INSTANCES
