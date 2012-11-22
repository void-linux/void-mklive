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
    inst chmod sed
    inst_hook pre-pivot 01 "$moddir/adduser.sh"
    inst_hook pre-pivot 02 "$moddir/conf.sh"
    inst_hook pre-pivot 03 "$moddir/polkit.sh"
    inst_hook pre-pivot 04 "$moddir/display-manager-autologin.sh"
}
