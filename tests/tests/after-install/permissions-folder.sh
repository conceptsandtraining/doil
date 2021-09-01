#!/bin/bash

ls -la ${1} | sed -n 2p | cut -d " " -f 1