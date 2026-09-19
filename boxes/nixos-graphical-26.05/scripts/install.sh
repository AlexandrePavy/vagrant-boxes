#!/bin/sh

set -eux

DISK=/dev/vda

echo "Installing NixOS on ${DISK}"

# Partition disk
parted -s "$DISK" \
  mklabel msdos \
  mkpart primary ext4 1MiB 100% \
  set 1 boot on

# Create filesystem
mkfs.ext4 -L nixos "${DISK}1"

# Mount
mount LABEL=nixos /mnt

# Generate hardware configuration
nixos-generate-config --root /mnt

# Install configuration
curl -sf \
  "$PACKER_HTTP_ADDR/configuration.nix" \
  -o /mnt/etc/nixos/configuration.nix

# Install NixOS
nixos-install --no-root-passwd
