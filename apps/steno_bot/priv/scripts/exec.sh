#!/bin/bash
NAME=$1
CMD=$2

lxc exec "$NAME" -- bash -c "$CMD"
