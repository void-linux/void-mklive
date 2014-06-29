#!/bin/sh
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

# Copy the initramfs back to the new rootfs for proper shutdown.
KVER=$(uname -r)
if [ -x /usr/bin/systemctl ]; then
    cp /run/initramfs/live/boot/initrd $NEWROOT/boot/initramfs-${KVER}.img
fi
