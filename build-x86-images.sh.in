#!/bin/sh

set -eu

ARCH=$(uname -m)
IMAGES="base enlightenment xfce mate cinnamon gnome kde lxde lxqt"
REPO=
DATE=$(date +%Y%m%d)

help() {
    echo "${0#/*}: [-a arch] [-b base|enlightenment|xfce|mate|cinnamon|gnome|kde|lxde|lxqt] [-r repo]" >&2
}

while getopts "a:b:hr:" opt; do
case $opt in
    a) ARCH="$OPTARG";;
    b) IMAGES="$OPTARG";;
    h) help; exit 0;;
    r) REPO="-r $OPTARG $REPO";;
    *) help; exit 1;;
esac
done
shift $((OPTIND - 1))

build_variant() {
    variant="$1"
    IMG=void-live-${ARCH}-${DATE}-${variant}.iso
    GRUB_PKGS="grub-i386-efi grub-x86_64-efi"
    PKGS="dialog cryptsetup lvm2 mdadm void-docs-browse xtools-minimal $GRUB_PKGS"
    XORG_PKGS="xorg-minimal xorg-input-drivers xorg-video-drivers setxkbmap xauth font-misc-misc terminus-font dejavu-fonts-ttf alsa-plugins-pulseaudio"
    SERVICES="sshd"

    case $variant in
        base)
            SERVICES="$SERVICES dhcpcd wpa_supplicant acpid"
        ;;
        enlightenment)
            PKGS="$PKGS $XORG_PKGS lxdm enlightenment terminology udisks2 firefox"
            SERVICES="$SERVICES acpid dhcpcd wpa_supplicant lxdm dbus polkitd"
        ;;
        xfce)
            PKGS="$PKGS $XORG_PKGS lxdm xfce4 gnome-themes-standard gnome-keyring network-manager-applet gvfs-afc gvfs-mtp gvfs-smb udisks2 firefox"
            SERVICES="$SERVICES dbus elogind lxdm NetworkManager polkitd"
        ;;
        mate)
            PKGS="$PKGS $XORG_PKGS lxdm mate mate-extra gnome-keyring network-manager-applet gvfs-afc gvfs-mtp gvfs-smb udisks2 firefox"
            SERVICES="$SERVICES dbus elogind lxdm NetworkManager polkitd"
        ;;
        cinnamon)
            PKGS="$PKGS $XORG_PKGS lxdm cinnamon gnome-keyring colord gnome-terminal gvfs-afc gvfs-mtp gvfs-smb udisks2 firefox"
            SERVICES="$SERVICES dbus elogind lxdm NetworkManager polkitd"
        ;;
        gnome)
            PKGS="$PKGS $XORG_PKGS gnome firefox"
            SERVICES="$SERVICES dbus elogind gdm NetworkManager polkitd"
        ;;
        kde)
            PKGS="$PKGS $XORG_PKGS kde5 konsole firefox dolphin"
            SERVICES="$SERVICES dbus elogind NetworkManager sddm"
        ;;
        lxde)
            PKGS="$PKGS $XORG_PKGS lxde lxdm gvfs-afc gvfs-mtp gvfs-smb udisks2 firefox"
            SERVICES="$SERVICES acpid dbus dhcpcd wpa_supplicant lxdm polkitd"
        ;;
        lxqt)
            PKGS="$PKGS $XORG_PKGS lxqt lxdm gvfs-afc gvfs-mtp gvfs-smb udisks2 firefox"
            SERVICES="$SERVICES elogind dbus dhcpcd wpa_supplicant lxdm polkitd"
        ;;
        *)
            >&2 echo "Unknown variant $variant"
            exit 1
        ;;
    esac

    ./mklive.sh -a "$ARCH" -o "$IMG" -p "$PKGS" -S "$SERVICES" ${REPO} "$@"
}

if [ ! -x mklive.sh ]; then
    echo mklive.sh not found >&2
    exit 1
fi

for image in $IMAGES; do
    build_variant "$image"
done
