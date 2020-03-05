#!/bin/bash
trap : TERM INT
(while true; do tail -f /dev/null ; done) & wait
