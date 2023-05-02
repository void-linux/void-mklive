#!/bin/bash
xorg_base

PKGS+=("lightdm" "cinnamon" "gnome-keyring" "colord" "gnome-terminal" "gvfs-afc" "gvfs-mtp" "gvfs-smb" "udisks2" "firefox")
SERVICES+=("dbus" "elogind" "lightdm" "NetworkManager" "polkitd")
