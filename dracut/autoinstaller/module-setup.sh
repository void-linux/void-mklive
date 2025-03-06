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
    inst /usr/bin/chmod
    inst /usr/bin/chroot
    inst /usr/bin/clear
    inst /usr/bin/cp
    inst /usr/bin/chpasswd
    inst /usr/bin/dhclient
    inst /usr/bin/dhclient-script
    inst /usr/bin/halt
    inst /usr/bin/install
    inst /usr/bin/jq
    inst /usr/bin/lsblk
    inst /usr/bin/mkdir
    inst /usr/bin/mkfs.ext4
    inst /usr/bin/mkswap
    inst /usr/bin/mount
    inst /usr/bin/resolvconf
    inst /usr/bin/sfdisk
    inst /usr/bin/sync
    inst /usr/bin/xbps-install
    inst /usr/bin/xbps-uhelper
    inst /usr/bin/xbps-query

    inst_multiple /var/db/xbps/keys/*
    inst_multiple /usr/share/xbps.d/*

    inst_multiple /etc/ssl/certs/*
    inst /etc/ssl/certs.pem

    inst_hook pre-mount 01 "$moddir/install.sh"
    inst_hook cmdline 99 "$moddir/parse-vai-root.sh"
    inst "$moddir/autoinstall.cfg" /etc/autoinstall.default
}
