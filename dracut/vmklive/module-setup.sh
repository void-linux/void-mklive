#!/bin/bash
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

check() {
    return 255
}

depends() {
    echo dmsquash-live
}

install() {
    inst /usr/bin/chroot
    inst /usr/bin/chmod
    inst /usr/bin/sed

    if [ -e /usr/bin/memdiskfind ]; then
        inst /usr/bin/memdiskfind
        instmods mtdblock phram
        inst_rules "$moddir/59-mtd.rules" "$moddir/61-mtd.rules"
        prepare_udev_rules 59-mtd.rules 61-mtd.rules
        inst_hook pre-udev 01 "$moddir/mtd.sh"
    fi

    inst_hook pre-pivot 01 "$moddir/adduser.sh"
    inst_hook pre-pivot 02 "$moddir/display-manager-autologin.sh"
    inst_hook pre-pivot 02 "$moddir/getty-serial.sh"
    inst_hook pre-pivot 03 "$moddir/locale.sh"
    inst_hook pre-pivot 04 "$moddir/accessibility.sh"
    inst_hook pre-pivot 05 "$moddir/nomodeset.sh"
}
