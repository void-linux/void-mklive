#!/bin/sh

set -eu

. ./lib.sh

PROGNAME=$(basename "$0")
ARCH=$(uname -m)
IMAGES="base enlightenment xfce mate cinnamon gnome kde lxde lxqt"
TRIPLET=
REPO=
DATE=$(date -u +%Y%m%d)

help() {
    echo "$PROGNAME: [-a arch] [-b base|enlightenment|xfce|mate|cinnamon|gnome|kde|lxde|lxqt] [-d date] [-t arch-date-variant] [-r repo]" >&2
}

while getopts "a:b:d:t:hr:V" opt; do
case $opt in
    a) ARCH="$OPTARG";;
    b) IMAGES="$OPTARG";;
    d) DATE="$OPTARG";;
    h) help; exit 0;;
    r) REPO="-r $OPTARG $REPO";;
    t) TRIPLET="$OPTARG";;
    V) version; exit 0;;
    *) help; exit 1;;
esac
done
shift $((OPTIND - 1))

INCLUDEDIR=$(mktemp -d)
trap "cleanup" INT TERM

cleanup() {
    rm -r "$INCLUDEDIR"
}

build_variant() {
    variant="$1"
    shift
    IMG=void-live-${ARCH}-${DATE}-${variant}.iso
    GRUB_PKGS="grub-i386-efi grub-x86_64-efi"
    PKGS="dialog cryptsetup lvm2 mdadm void-docs-browse xtools-minimal xmirror $GRUB_PKGS"
    PKGS="dialog cryptsetup lvm2 mdadm void-docs-browse xtools-minimal xmirror espeakup $GRUB_PKGS"
    XORG_PKGS="xorg-minimal xorg-input-drivers xorg-video-drivers setxkbmap xauth font-misc-misc terminus-font dejavu-fonts-ttf alsa-plugins-pulseaudio"
    SERVICES="sshd"

    LIGHTDM_SESSION=''

    case $variant in
        base)
            SERVICES="$SERVICES dhcpcd wpa_supplicant acpid"
        ;;
        enlightenment)
            PKGS="$PKGS $XORG_PKGS lightdm lightdm-gtk3-greeter enlightenment terminology udisks2 firefox"
            SERVICES="$SERVICES acpid dhcpcd wpa_supplicant lightdm dbus polkitd"
            LIGHTDM_SESSION=enlightenment
        ;;
        xfce)
            PKGS="$PKGS $XORG_PKGS lightdm lightdm-gtk3-greeter xfce4 gnome-themes-standard gnome-keyring network-manager-applet gvfs-afc gvfs-mtp gvfs-smb udisks2 firefox"
            SERVICES="$SERVICES dbus elogind lightdm NetworkManager polkitd"
            LIGHTDM_SESSION=xfce
        ;;
        mate)
            PKGS="$PKGS $XORG_PKGS lightdm lightdm-gtk3-greeter mate mate-extra gnome-keyring network-manager-applet gvfs-afc gvfs-mtp gvfs-smb udisks2 firefox"
            SERVICES="$SERVICES dbus elogind lightdm NetworkManager polkitd"
            LIGHTDM_SESSION=mate
        ;;
        cinnamon)
            PKGS="$PKGS $XORG_PKGS lightdm lightdm-gtk3-greeter cinnamon gnome-keyring colord gnome-terminal gvfs-afc gvfs-mtp gvfs-smb udisks2 firefox"
            SERVICES="$SERVICES dbus elogind lightdm NetworkManager polkitd"
            LIGHTDM_SESSION=cinnamon
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
            PKGS="$PKGS $XORG_PKGS lxde lightdm lightdm-gtk3-greeter gvfs-afc gvfs-mtp gvfs-smb udisks2 firefox"
            SERVICES="$SERVICES acpid dbus dhcpcd wpa_supplicant lightdm polkitd"
            LIGHTDM_SESSION=LXDE
        ;;
        lxqt)
            PKGS="$PKGS $XORG_PKGS lxqt sddm gvfs-afc gvfs-mtp gvfs-smb udisks2 firefox"
            SERVICES="$SERVICES elogind dbus dhcpcd wpa_supplicant sddm polkitd"
        ;;
        *)
            >&2 echo "Unknown variant $variant"
            exit 1
        ;;
    esac

    if [ -n "$LIGHTDM_SESSION" ]; then
        mkdir -p "$INCLUDEDIR"/etc/lightdm
        echo "$LIGHTDM_SESSION" > "$INCLUDEDIR"/etc/lightdm/.session
    fi

    ./mklive.sh -a "$ARCH" -o "$IMG" -p "$PKGS" -S "$SERVICES" -I "$INCLUDEDIR" ${REPO} "$@"
}

if [ ! -x mklive.sh ]; then
    echo mklive.sh not found >&2
    exit 1
fi

if [ -x installer.sh ]; then
    MKLIVE_VERSION="$(PROGNAME='' version)"
    installer=$(mktemp)
    sed "s/@@MKLIVE_VERSION@@/${MKLIVE_VERSION}/" installer.sh > "$installer"
    install -Dm755 "$installer" "$INCLUDEDIR"/usr/bin/void-installer
    rm "$installer"
else
    echo installer.sh not found >&2
    exit 1
fi

if [ -n "$TRIPLET" ]; then
    VARIANT="${TRIPLET##*-}"
    REST="${TRIPLET%-*}"
    DATE="${REST##*-}"
    ARCH="${REST%-*}"
    build_variant "$VARIANT" "$@"
else
    for image in $IMAGES; do
        build_variant "$image" "$@"
    done
fi
