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

# Configure sddm autologin for the kde iso.
if [ -x ${NEWROOT}/usr/bin/sddm ]; then
    cat > ${NEWROOT}/etc/sddm.conf <<_EOF
[Autologin]
User=${USERNAME}
Session=plasma.desktop
_EOF
fi

# Configure lightdm autologin.
if [ -r "${NEWROOT}/etc/lightdm/lightdm.conf" ]; then
    sed -i -e "s|^\#\(autologin-user=\).*|\1$USERNAME|" \
        "${NEWROOT}/etc/lightdm/lightdm.conf"
    sed -i -e "s|^\#\(autologin-user-timeout=\).*|\10|" \
        "${NEWROOT}/etc/lightdm/lightdm.conf"
    sed -i -e "s|^\#\(autologin-session=\).*|\1$(cat "${NEWROOT}/etc/lightdm/.session")|" \
        "${NEWROOT}/etc/lightdm/lightdm.conf"
    sed -i -e "s|^\#\(user-session=\).*|\1$(cat "${NEWROOT}/etc/lightdm/.session")|" \
        "${NEWROOT}/etc/lightdm/lightdm.conf"
fi

# Configure lxdm autologin.
if [ -r ${NEWROOT}/etc/lxdm/lxdm.conf ]; then
    sed -e "s,.*autologin.*=.*,autologin=$USERNAME," -i ${NEWROOT}/etc/lxdm/lxdm.conf
    if [ -x ${NEWROOT}/usr/bin/enlightenment_start ]; then
        sed -e "s,.*session.*=.*,session=/usr/bin/enlightenment_start," -i ${NEWROOT}/etc/lxdm/lxdm.conf
    elif [ -x ${NEWROOT}/usr/bin/startxfce4 ]; then
        sed -e "s,.*session.*=.*,session=/usr/bin/startxfce4," -i ${NEWROOT}/etc/lxdm/lxdm.conf
    elif [ -x ${NEWROOT}/usr/bin/mate-session ]; then
        sed -e "s,.*session.*=.*,session=/usr/bin/mate-session," -i ${NEWROOT}/etc/lxdm/lxdm.conf
    elif [ -x ${NEWROOT}/usr/bin/cinnamon-session ]; then
        sed -e "s,.*session.*=.*,session=/usr/bin/cinnamon-session," -i ${NEWROOT}/etc/lxdm/lxdm.conf
    elif [ -x ${NEWROOT}/usr/bin/i3 ]; then
        sed -e "s,.*session.*=.*,session=/usr/bin/i3," -i ${NEWROOT}/etc/lxdm/lxdm.conf
    elif [ -x ${NEWROOT}/usr/bin/startlxde ]; then
        sed -e "s,.*session.*=.*,session=/usr/bin/startlxde," -i ${NEWROOT}/etc/lxdm/lxdm.conf
    elif [ -x ${NEWROOT}/usr/bin/startlxqt ]; then
        sed -e "s,.*session.*=.*,session=/usr/bin/startlxqt," -i ${NEWROOT}/etc/lxdm/lxdm.conf
    elif [ -x ${NEWROOT}/usr/bin/startfluxbox ]; then
        sed -e "s,.*session.*=.*,session=/usr/bin/startfluxbox," -i ${NEWROOT}/etc/lxdm/lxdm.conf
    fi
fi
