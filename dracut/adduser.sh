#!/bin/sh
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

type getarg >/dev/null 2>&1 || . /lib/dracut-lib.sh

echo void-live > ${NEWROOT}/etc/hostname

USERNAME=$(getarg live.user)
[ -z "$USERNAME" ] && USERNAME=anon

# Create /etc/default/live.conf to store USER.
echo "USERNAME=$USERNAME" >> ${NEWROOT}/etc/default/live.conf
chmod 644 ${NEWROOT}/etc/default/live.conf

# Create new user and remove password. We'll use autologin by default.
chroot ${NEWROOT} useradd -c $USERNAME -m $USERNAME -G wheel -s /bin/bash
chroot ${NEWROOT} passwd -d $USERNAME >/dev/null 2>&1

# Setup default root password (voidlinux).
chroot ${NEWROOT} sh -c 'echo "root:voidlinux" | chpasswd -c SHA512'

# Enable sudo permission by default.
if [ -f ${NEWROOT}/etc/sudoers ]; then
    echo "${USERNAME}  ALL=(ALL) NOPASSWD: ALL" >> ${NEWROOT}/etc/sudoers
fi

# Enable autologin for agetty(8) on tty1 with runit.
if [ -d ${NEWROOT}/etc/runit ]; then
    sed -e "s|\-8|& -a $USERNAME|g" -i ${NEWROOT}/etc/sv/agetty-tty1/run
fi

# Enable autologin for agetty(8) on tty1 with systemd.
if [ -d ${NEWROOT}/etc/systemd/system ]; then
    rm -f "${NEWROOT}/etc/systemd/system/getty.target.wants/getty@tty1.service"
    sed -e "s|/sbin/agetty --noclear|& -a ${USERNAME}|g" \
        "${NEWROOT}/usr/lib/systemd/system/getty@.service" > \
        "${NEWROOT}/etc/systemd/system/getty@.service"
    ln -sf /etc/systemd/system/getty@.service \
        "${NEWROOT}/etc/systemd/system/getty.target.wants/getty@tty1.service"
fi

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
