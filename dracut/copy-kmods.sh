#!/bin/sh
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

# Copy all modules from initramfs to new rootfs.
mkdir -p $NEWROOT/usr/lib/modules
cp -a /usr/lib/modules/* $NEWROOT/usr/lib/modules
