#!/bin/bash

# snippets used in individual variants to avoid repetition
base() {
    PKGS+=("base-system")
    if [ "$SETUP_TYPE" = "iso" ]; then
        PKGS+=("dialog" "cryptsetup" "lvm2" "mdadm" "void-docs-browse" "xtools-minimal" "grub-i386-efi" "grub-x86_64-efi")
        SERVICES+=("sshd")
    elif [ "$SETUP_TYPE" = "system" ]; then
        if [ -n "$EFI_SYSTEM" ]; then
            if [ "$EFI_FW_BITS" -eq 32 ]; then
                PKGS+=("grub-i386-efi")
            else
                PKGS+=("grub-x86_64-efi")
            fi
        else
            PKGS+=("grub")
        fi
    fi

}

xorg_base() {
    base
    PKGS+=("xorg-minimal" "xorg-input-drivers" "xorg-video-drivers" "setxkbmap" "xauth" "font-misc-misc" "terminus-font" "dejavu-fonts-ttf" "alsa-plugins-pulseaudio")
}

deduplicate() {
    printf "%s\n" $@ | sort -u | tr '\n' ' '
}

# set PKGS, SERVICES and other variables based on which variant we want to set up for
setup_variant() {
    variant="$1" # xfce, base, gnome, etc.
    . "setupscripts/variants/$variant.sh"
    PKGSSTR=$(deduplicate "${PKGS[@]}")
    SERVICESSTR=$(deduplicate "${SERVICES[@]}")
}
