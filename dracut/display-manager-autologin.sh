#!/bin/sh
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

type getarg >/dev/null 2>&1 || . /lib/dracut-lib.sh

USERNAME=$(getarg live.user)
[ -z "$USERNAME" ] && USERNAME=anon

# Configure GDM autologin
if [ -d ${NEWROOT}/etc/gdm ]; then
    GDMCustomFile=${NEWROOT}/etc/gdm/custom.conf
    AutologinParameters="AutomaticLoginEnable=true\nAutomaticLogin=$USERNAME"

    # Prevent from updating if parameters already present (persistent usb key)
    if ! `grep -qs 'AutomaticLoginEnable' $GDMCustomFile` ; then
        if ! `grep -qs '\[daemon\]' $GDMCustomFile` ; then
            echo '[daemon]' >> $GDMCustomFile
        fi
        sed -i "s/\[daemon\]/\[daemon\]\n$AutologinParameters/" $GDMCustomFile
    fi
fi

# Configure lightdm autologin.
if [ -r ${NEWROOT}/etc/lightdm.conf ]; then
    sed -i -e "s|^\#\(default-user=\).*|\1$USERNAME|" \
        ${NEWROOT}/etc/lightdm.conf
    sed -i -e "s|^\#\(default-user-timeout=\).*|\10|" \
        ${NEWROOT}/etc/lightdm.conf
fi

# Configure lxdm autologin.
if [ -r ${NEWROOT}/etc/lxdm/lxdm.conf ]; then
    sed -e "s,.*autologin.*=.*,autologin=$USERNAME," -i ${NEWROOT}/etc/lxdm/lxdm.conf
    if [ -x ${NEWROOT}/usr/bin/enlightenment_start ]; then
        sed -e "s,.*session.*=.*,session=/usr/bin/enlightenment_start," -i ${NEWROOT}/etc/lxdm/lxdm.conf
    fi
fi
