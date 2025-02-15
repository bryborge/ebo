#!/usr/bin/env bash

set -xe

while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done

sudo rm /etc/ssh/ssh_host_*
sudo truncate -s 0 /etc/machine-id
sudo cloud-init clean
sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg
sudo sync
