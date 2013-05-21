#!/bin/sh
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

# Regen locales if it's set in the kernel cmdline.

type getarg >/dev/null 2>&1 || . /lib/dracut-lib.sh

LOCALE=$(getarg locale.LANG)
[ -z "$LOCALE" ] && LOCALE="en_US.UTF-8"

# Create new user and remove password. We'll use autologin by default.
sed -e "s,^\#\($LOCALE.*\),\1," -i $NEWROOT/etc/default/libc-locales
chroot $NEWROOT xbps-reconfigure -f glibc-locales >/dev/null 2>&1

# also enable this locale in newroot.
echo "LANG=$LOCALE" > $NEWROOT/etc/locale.conf
echo "LC_COLLATE=C" >> $NEWROOT/etc/locale.conf

# set keymap too.
KEYMAP=$(getarg vconsole.keymap)
[ -z "$KEYMAP" ] && KEYMAP="us"
sed -e "s,^KEYMAP=.*,KEYMAP=$KEYMAP," -i $NEWROOT/etc/vconsole.conf
