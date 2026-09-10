#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "==> Removing unused packages and old kernels"
apt-get autoremove --purge -y
apt-get clean

echo "==> Cleaning APT cache and lists"
rm -rf /var/lib/apt/lists/*

echo "==> Cleaning shell history"
rm -f /root/.bash_history
rm -f /home/vagrant/.bash_history

echo "==> Cleaning journal logs"
journalctl --rotate
journalctl --vacuum-time=1s

echo "==> Removing SSH host keys for regeneration on first boot"
rm -f /etc/ssh/ssh_host_*

echo "==> Cleaning cloud-init state"
cloud-init clean --logs --seed --machine-id

echo "==> Cleaning completed"
