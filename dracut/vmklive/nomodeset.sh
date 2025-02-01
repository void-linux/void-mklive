#!/bin/sh
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

type getargbool >/dev/null 2>&1 || . /lib/dracut-lib.sh

if getargbool 0 nomodeset; then
    for dm in lightdm sddm gdm; do
        if [ -e "${NEWROOT}/etc/sv/${dm}" ]; then
            :> "${NEWROOT}/etc/sv/${dm}/down"
        fi
    done
fi
