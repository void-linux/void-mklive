#!/bin/sh
set -eux

# Varsayılanlar
ARCH=x86_64
REPO=https://repo.voidlinux.org/current
OUT=void-live-${ARCH}-zfs.iso

sudo /bin/bash ./mklive.sh \
  -a "${ARCH}" \
  -r "${REPO}" \
  -p "zfs zfs-utils" \
  -o "${OUT}"
