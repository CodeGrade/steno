#!/bin/bash

NAME=steno-base

lxc image delete $NAME
lxc delete $NAME
lxc launch ubuntu:16.04 $NAME

echo "Waiting for container to boot..."
while [[ ! `lxc exec "$NAME" -- runlevel` =~ ^N ]]; do
    sleep 1
done

echo "Running apt..."
lxc exec $NAME -- bash <<END
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get upgrade -y
apt-get install -y openjdk-8-jdk build-essential \
    clang python3 ruby libipc-system-simple-perl
END

echo "Stopping; Publishing..."
lxc stop $NAME
lxc publish $NAME --alias steno-base
lxc delete $NAME

