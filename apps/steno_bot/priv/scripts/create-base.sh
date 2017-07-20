#!/bin/bash

NAME=steno-base

lxc image delete $NAME
lxc delete $NAME
lxc launch ubuntu:16.04 $NAME

echo "Waiting for container to boot..."
while [[ ! `lxc exec "$NAME" -- runlevel` =~ ^N ]]; do
    sleep 1
done

lxc exec $NAME -- DEBIAN_FRONTEND=noninteractive \
    apt-get update
lxc exec $NAME -- DEBIAN_FRONTEND=noninteractive \
    apt-get upgrade -y
lxc exec $NAME -- DEBIAN_FRONTEND=noninteractive \
    apt-get install -y openjdk-8-jdk gradle build-essential clang python3 ruby \
        libipc-system-simple-perl

lxc stop $NAME
lxc publish $NAME --alias steno-base
lxc delete $NAME

