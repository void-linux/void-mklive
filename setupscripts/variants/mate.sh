#!/bin/bash
xorg_base

PKGS+=("lightdm" "mate" "mate-extra" "gnome-keyring" "network-manager-applet" "gvfs-afc" "gvfs-mtp" "gvfs-smb" "udisks2" "firefox")
SERVICES+=("dbus" "elogind" "lightdm" "NetworkManager" "polkitd")
