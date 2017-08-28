#!/bin/bash
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

check() {
    return 255
}

depends() {
    echo network
}

install() {
    inst /usr/bin/awk
    inst /usr/bin/basename
    inst /usr/bin/bash
    inst /usr/bin/cat
    inst /usr/bin/cfdisk
    inst /usr/bin/chroot
    inst /usr/bin/clear
    inst /usr/bin/cut
    inst /usr/bin/cp
    inst /usr/bin/dhcpcd
    inst /usr/bin/dialog
    inst /usr/bin/echo
    inst /usr/bin/env
    inst /usr/bin/find
    inst /usr/bin/find
    inst /usr/bin/grep
    inst /usr/bin/head
    inst /usr/bin/id
    inst /usr/bin/ln
    inst /usr/bin/ls
    inst /usr/bin/lsblk
    inst /usr/bin/mke2fs
    inst /usr/bin/mkfs.btrfs
    inst /usr/bin/mkfs.f2fs
    inst /usr/bin/mkfs.vfat
    inst /usr/bin/mkfs.xfs
    inst /usr/bin/mkswap
    inst /usr/bin/mktemp
    inst /usr/bin/mount
    inst /usr/bin/reboot
    inst /usr/bin/rm
    inst /usr/bin/sed
    inst /usr/bin/sh
    inst /usr/bin/sort
    inst /usr/bin/sync
    inst /usr/bin/stdbuf
    inst /usr/bin/sleep
    inst /usr/bin/touch
    inst /usr/bin/xargs
    inst /usr/bin/xbps-install
    inst /usr/bin/xbps-reconfigure
    inst /usr/bin/xbps-remove
    inst /usr/bin/xbps-uhelper

    inst /usr/libexec/dhcpcd-hooks/20-resolv.conf
    inst /usr/libexec/dhcpcd-run-hooks
    inst /usr/libexec/coreutils/libstdbuf.so

    inst_multiple /var/db/xbps/keys/*
    inst_multiple /usr/share/xbps.d/*
    inst_multiple /usr/share/zoneinfo/*/*

    inst_multiple /etc/ssl/certs/*
    inst /etc/ssl/certs.pem

    inst /etc/default/libc-locales
    inst /etc/group

    # We need to remove a choice here since the installer's initrd
    # can't function as a local source.  Strictly we shouldn't be
    # doing this from dracut's installation function, but this is the
    # last place that file really exists 'on disk' in the sense that
    # we can modify it, so this change is applied here.
    sed -i '/Packages from ISO image/d' "$moddir/installer.sh"

    # The system doesn't have a real init up so the reboot is going to
    # be rough, we make it an option though if the end user wants to
    # do this...
    sed -i "s:shutdown -r now:sync && reboot -f:" "$moddir/installer.sh"

    inst "$moddir/installer.sh" /usr/bin/void-installer
    inst_hook pre-mount 05 "$moddir/netmenu.sh"
}
