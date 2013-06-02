#!/bin/sh
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

type getarg >/dev/null 2>&1 || . /lib/dracut-lib.sh

USERNAME=$(getarg live.user)
[ -z "$USERNAME" ] && USERNAME=anon

# Create /etc/default/live.conf to store USER.
echo "USERNAME=$USERNAME" >> ${NEWROOT}/etc/default/live.conf
chmod 644 ${NEWROOT}/etc/default/live.conf

# Create new user and remove password. We'll use autologin by default.
chroot ${NEWROOT} useradd -c $USERNAME -m $USERNAME -G \
    systemd-journal,wheel -s /bin/bash
chroot ${NEWROOT} passwd -d $USERNAME >/dev/null 2>&1

# Enable sudo permission by default.
if [ -f ${NEWROOT}/etc/sudoers ]; then
    echo "${USERNAME}  ALL=(ALL) NOPASSWD: ALL" >> ${NEWROOT}/etc/sudoers
fi

# Enable autologin for agetty(8).
rm -f "${NEWROOT}/etc/systemd/system/getty.target.wants/getty@tty1.service"
sed -e "s|/sbin/agetty --noclear|& -a ${USERNAME}|g" \
    "${NEWROOT}/usr/lib/systemd/system/getty@.service" > \
    "${NEWROOT}/etc/systemd/system/getty.target.wants/getty@tty1.service"

if [ -d ${NEWROOT}/etc/polkit-1 ]; then
    # If polkit is installed allow users in the wheel group to run anything.
    cat > ${NEWROOT}/etc/polkit-1/rules.d/void-live.rules <<_EOF
polkit.addAdminRule(function(action, subject) {
    return ["unix-group:wheel"];
});

polkit.addRule(function(action, subject) {
    if (subject.isInGroup("wheel")) {
        return polkit.Result.YES;
    }
});
_EOF
    chroot ${NEWROOT} chown polkitd:polkitd /etc/polkit-1/rules.d/void-live.rules
fi
