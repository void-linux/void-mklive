#!/bin/bash
xorg_base

PKGS+=("lxqt" "lightdm" "gvfs-afc" "gvfs-mtp" "gvfs-smb" "udisks2" "firefox")
SERVICES+=("elogind" "dbus" "dhcpcd" "wpa_supplicant" "lightdm" "polkitd")
