#!/bin/sh
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

USERNAME=$(getarg live.user)
[ -z "$USERNAME" ] && USERNAME=anon

# Create /etc/default/live.conf to store USER.
echo "USERNAME=$USERNAME" >> ${NEWROOT}/etc/default/live.conf
chmod 644 ${NEWROOT}/etc/default/live.conf

# Create new user and remove password. We'll use autologin by default.
chroot ${NEWROOT} useradd -c $USERNAME -m $USERNAME -G audio,video,wheel -s /bin/sh
chroot ${NEWROOT} passwd -d $USERNAME 2>&1 >/dev/null

# Enable sudo permission by default.
if [ -f ${NEWROOT}/etc/sudoers ]; then
	echo "${USERNAME}  ALL=(ALL) NOPASSWD: ALL" >> ${NEWROOT}/etc/sudoers
fi

# Enable autologin for getty(1).
if [ -f ${NEWROOT}/usr/lib/systemd/system/getty@.service ]; then
        rm -f "${NEWROOT}/etc/systemd/system/getty.target.wants/getty@tty1.service"
	sed -e "s|/sbin/agetty --noclear|/usr/sbin/live-getty|g" \
                "${NEWROOT}/usr/lib/systemd/system/getty@.service" > \
                "${NEWROOT}/etc/systemd/system/getty.target.wants/getty@tty1.service"
fi

# Create /usr/sbin/live-getty.
cat > ${NEWROOT}/usr&sbin/live-getty <<_EOF
#!/bin/sh

if [ -x /usr/sbin/agetty ]; then
	_getty=/usr&sbin/agetty
elif [ -x /usr/sbin/getty ]; then
	_getty=/usr/sbin/getty
fi

exec \${_getty} -n -l /usr/sbin/live-autologin \$*
_EOF
chmod 755 ${NEWROOT}/usr/sbin/live-getty

# Create /usr/sbin/live-autologin.
cat > ${NEWROOT}/usr/sbin/live-autologin <<_EOF
#!/bin/sh

. /etc/default/live.conf
exec /usr/bin/login -f \$USERNAME
_EOF
chmod 755 ${NEWROOT}/usr/sbin/live-autologin
