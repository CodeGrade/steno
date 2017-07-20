#!/bin/bash
NAME=$1
SRC=$2
DST=$3

lxc file push "$SRC" "$NAME/$DST"
