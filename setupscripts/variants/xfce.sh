#!/bin/bash
xorg_base

PKGS+=("lightdm" "xfce4" "gnome-themes-standard" "gnome-keyring" "network-manager-applet" "gvfs-afc" "gvfs-mtp" "gvfs-smb" "udisks2" "firefox")
SERVICES+=("dbus" "elogind" "lightdm" "NetworkManager" "polkitd")
