#!/bin/bash
BASE=bn-base
NAME=$1

lxc launch "$BASE" "$NAME" -e \
    -c "limits.cpu.allowance=25ms/50ms" \
    -c "limits.memory=512MB" \
    -c "limits.processes=256"

echo "Waiting for container to boot..."
while [[ ! `lxc exec "$NAME" -- runlevel` =~ ^N ]]; do
    sleep 1
done

echo "Container ready: $NAME"

