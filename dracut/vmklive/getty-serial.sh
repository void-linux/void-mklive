#!/bin/sh
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

type getarg >/dev/null 2>&1 || . /lib/dracut-lib.sh

CONSOLE=$(getarg console)
case "$CONSOLE" in
*ttyS0*)
        ln -s /etc/sv/agetty-ttyS0 ${NEWROOT}/etc/runit/runsvdir/default/
        ;;
*hvc0*)
        ln -s /etc/sv/agetty-hvc0 ${NEWROOT}/etc/runit/runsvdir/default/
        ;;
*hvsi0*)
        ln -s /etc/sv/agetty-hvsi0 ${NEWROOT}/etc/runit/runsvdir/default/
        ;;
esac
