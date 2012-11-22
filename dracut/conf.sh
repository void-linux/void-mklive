#!/bin/sh
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

type getarg >/dev/null 2>&1 || . /lib/dracut-lib.sh

KEYMAP=$(getarg vconsole.keymap)
FONT=$(getarg vconsole.font)
FONT_MAP=$(getarg vconsole.font.map)
FONT_UNIMAP=$(getarg vconsole.font.unimap)
LOCALE=$(getarg locale.LANG)

if [ -n "$KEYMAP" ]; then
    sed -i -e "s|^KEYMAP=.*|KEYMAP=$KEYMAP|g" ${NEWROOT}/etc/vconsole.conf
fi
if [ -n "$FONT" ]; then
    sed -i -e "s|^FONT=.*|FONT=$FONT|g" ${NEWROOT}/etc/vconsole.conf
fi
if [ -n "$FONT_MAP" ]; then
    sed -i -e "s|^FONT_MAP=.*|FONT_MAP=$FONT_MAP|g" ${NEWROOT}/etc/vconsole.conf
fi
if [ -n "$FONT_UNIMAP" ]; then
    sed -i -e "s|^FONT_UNIMAP=.*|FONT_UNIMAP=$FONT_UNIMAP|g" ${NEWROOT}/etc/vconsole.conf
fi
if [ -n "$LOCALE" ]; then
    sed -i -e "s|^LANG=.*|LANG=$LOCALE|g" ${NEWROOT}/etc/locale.conf
fi

# Setup keymap for X.org evdev.
if [ -r "${NEWROOT}/etc/udev/rules.d/75-x11-input.rules" ]; then
    sed -i -e "s|\(ENV{xkblayout}\=\)\"us\"|\1\"${KEYMAP}\"|" \
        ${NEWROOT}/etc/udev/rules.d/75-x11-input.rules
fi
