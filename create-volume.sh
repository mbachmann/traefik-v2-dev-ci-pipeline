#!/bin/bash

if [ ! "$(hcloud volume list | grep storage01)" ]; then
  echo "Creating and attaching volume name storage01 ..."
  hcloud volume create --format ext4 --server cas-oop-srv-01 --size 10 --name storage01 --automount
else
  hcloud volume attach storage01 --server cas-oop-srv-01  --automount
fi
