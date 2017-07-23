#!/bin/bash
NAME=$1
DRVR=$2

lxc file push "$DRVR" "$NAME/root/driver.pl"
lxc exec "$NAME" -- bash -c "perl /root/driver.pl"
