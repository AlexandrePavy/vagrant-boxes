#!/bin/sh

set -eux

echo "Cleaning up..."

nix-collect-garbage -d

rm -rf /boot/*-initrd*
rm -rf /boot/*-kernel*

truncate -s 0 /etc/machine-id

echo "==> Writing zeroes to free space (this could take a while)"
dd if=/dev/zero of=/EMPTY bs=1M status=progress || true
rm -f /EMPTY

sync

echo "==> Cleaning completed"
