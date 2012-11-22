#!/bin/sh
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

type getarg >/dev/null 2>&1 || . /lib/dracut-lib.sh

USERNAME=$(getarg live.user)
[ -z "$USERNAME" ] && USERNAME=anon

# Check that polkit is installed.
if [ ! -x ${NEWROOT}/usr/libexec/polkitd ]; then
    exit 0
fi

# configure PolicyKit in live session
mkdir -m0755 -p ${NEWROOT}/etc/PolicyKit
cat << EOF > ${NEWROOT}/etc/PolicyKit/PolicyKit.conf
<?xml version="1.0" encoding="UTF-8"?> <!-- -*- XML -*- -->

<!DOCTYPE pkconfig PUBLIC "-//freedesktop//DTD PolicyKit Configuration 1.0//EN"
"http://hal.freedesktop.org/releases/PolicyKit/1.0/config.dtd">

<!-- See the manual page PolicyKit.conf(5) for file format -->

<config version="0.1">
    <match user="root">
        <return result="yes"/>
    </match>
    <!-- don't ask password for user in live session -->
    <match user="$USERNAME">
        <return result="yes"/>
    </match>
    <define_admin_auth group="admin"/>
</config>
EOF

mkdir -m0750 -p ${NEWROOT}/var/lib/polkit-1/localauthority/10-vendor.d
cat << EOF > ${NEWROOT}/var/lib/polkit-1/localauthority/10-vendor.d/10-live-cd.pkla
# Policy to allow the livecd user to bypass policykit
[Live CD user permissions]
Identity=unix-user:$USERNAME
Action=*
ResultAny=no
ResultInactive=no
ResultActive=yes
EOF
