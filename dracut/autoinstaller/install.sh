#!/bin/sh

set -e

# These functions pulled from void's excellent mklive.sh
VAI_info_msg() {
    printf "\033[1m%s\n\033[m" "$@"
}

VAI_print_step() {
    CURRENT_STEP=$((CURRENT_STEP+1))
    VAI_info_msg "[${CURRENT_STEP}/${STEP_COUNT}] $*"
}

# ----------------------- Install Functions ------------------------

VAI_welcome() {
    clear
    printf "=============================================================\n"
    printf "================ Void Linux Auto-Installer ==================\n"
    printf "=============================================================\n"
}

VAI_get_address() {
    mkdir -p /var/lib/dhclient

    # This will fork, but it means that over a slow link the DHCP
    # lease will still be maintained.  It also doesn't have a
    # hard-coded privsep user in it like dhcpcd.
    dhclient
}

VAI_partition_disk() {
    # Paritition Disk
    sfdisk "${disk}" <<EOF
,$bootpartitionsize
,${swapsize}K
;
EOF
}

VAI_format_disk() {
    # Make Filesystems
    mkfs.ext4 -F "${disk}1"
    mkfs.ext4 -F "${disk}3"
    if [ "${swapsize}" -ne 0 ] ; then
        mkswap -f "${disk}2"
    fi
}

VAI_mount_target() {
    # Mount targetfs
    mkdir -p "${target}"
    mount "${disk}3" "${target}"
    mkdir "${target}/boot"
    mount "${disk}1" "${target}/boot"
}

VAI_install_xbps_keys() {
    mkdir -p "${target}/var/db/xbps/keys"
    cp /var/db/xbps/keys/* "${target}/var/db/xbps/keys"
}

VAI_install_base_system() {
    # Install a base system
    XBPS_ARCH="${XBPS_ARCH}" xbps-install -Sy -R "${xbpsrepository}" -r /mnt base-system grub

    # Install additional packages
    if [  -n "${pkgs}" ] ; then
        # shellcheck disable=SC2086
        XBPS_ARCH="${XBPS_ARCH}" xbps-install -Sy -R "${xbpsrepository}" -r /mnt ${pkgs}
    fi
}

VAI_prepare_chroot() {
    # Mount dev, bind, proc, etc into chroot
    mount -t proc proc "${target}/proc"
    mount --rbind /sys "${target}/sys"
    mount --rbind /dev "${target}/dev"
}

VAI_configure_sudo() {
    # Give wheel sudo
    echo "%wheel ALL=(ALL:ALL) ALL" > "${target}/etc/sudoers.d/00-wheel"
    chmod 0440 "${target}/etc/sudoers.d/00-wheel"
}

VAI_correct_root_permissions() {
    chroot "${target}" chown root:root /
    chroot "${target}" chmod 755 /
}

VAI_configure_hostname() {
    # Set the hostname
    echo "${hostname}" > "${target}/etc/hostname"
}

VAI_configure_rc_conf() {
    # Set the value of various tokens
    sed -i "s:Europe/Madrid:${timezone}:" "${target}/etc/rc.conf"
    sed -i "s:\"es\":\"${keymap}\":" "${target}/etc/rc.conf"

    # Activate various tokens
    sed -i "s:#HARDWARECLOCK:HARDWARECLOCK:" "${target}/etc/rc.conf"
    sed -i "s:#TIMEZONE:TIMEZONE:" "${target}/etc/rc.conf"
    sed -i "s:#KEYMAP:KEYMAP:" "${target}/etc/rc.conf"
}

VAI_add_user() {
    chroot "${target}" useradd -m -s /bin/bash -U -G wheel,users,audio,video,cdrom,input "${username}"
    if [ -z "${password}" ] ; then
        chroot "${target}" passwd "${username}"
    else
        # For reasons that remain unclear, this does not work in musl
        echo "${username}:${password}" | chpasswd -c SHA512 -R "${target}"
fi
}

VAI_configure_grub() {
    # Set hostonly
    echo "hostonly=yes" > "${target}/etc/dracut.conf.d/hostonly.conf"

    # Choose the newest kernel
    kernel_version="$(chroot "${target}" xbps-query linux | awk -F "[-_]" '/pkgver/ {print $2}')"

    # Install grub
    chroot "${target}" grub-install "${disk}"
    chroot "${target}" xbps-reconfigure -f "linux${kernel_version}"

    # Correct the grub install
    chroot "${target}" update-grub
}

VAI_configure_fstab() {
    # Grab UUIDs
    uuid1="$(blkid -s UUID -o value "${disk}1")"
    uuid2="$(blkid -s UUID -o value "${disk}2")"
    uuid3="$(blkid -s UUID -o value "${disk}3")"

    # Installl UUIDs into /etc/fstab
    echo "UUID=$uuid3 / ext4 defaults,errors=remount-ro 0 1" >> "${target}/etc/fstab"
    echo "UUID=$uuid1 /boot ext4 defaults 0 2" >> "${target}/etc/fstab"
    if [ "${swapsize}" -ne 0 ] ; then
        echo "UUID=$uuid2 swap swap defaults 0 0" >> "${target}/etc/fstab"
    fi
}

VAI_configure_locale() {
    # Set the libc-locale iff glibc
    case "${XBPS_ARCH}" in
        *-musl)
            VAI_info_msg "Glibc locales are not supported on musl"
            ;;
        *)
            sed -i "/${libclocale}/s/#//" "${target}/etc/default/libc-locales"

            chroot "${target}" xbps-reconfigure -f glibc-locales
            ;;
    esac
}

VAI_end_action() {
    case $end_action in
        reboot)
            VAI_info_msg "Rebooting the system"
            sync
            umount -R "${target}"
            reboot -f
            ;;
        shutdown)
            VAI_info_msg "Shutting down the system"
            sync
            umount -R "${target}"
            poweroff -f
            ;;
        script)
            VAI_info_msg "Running user provided script"
            xbps-uhelper fetch "${end_script}>/script"
            chmod +x /script
            target=${target} xbpsrepository=${xbpsrepository} /script
            ;;
        func)
            VAI_info_msg "Running user provided function"
            end_function
            ;;
    esac
}

VAI_configure_autoinstall() {
    # -------------------------- Setup defaults ---------------------------
    bootpartitionsize="500M"
    disk="$(lsblk -ipo NAME,TYPE,MOUNTPOINT | awk '{if ($2=="disk") {disks[$1]=0; last=$1} if ($3=="/") {disks[last]++}} END {for (a in disks) {if(disks[a] == 0){print a; break}}}')"
    hostname="$(ip -4 -o -r a | awk -F'[ ./]' '{x=$7} END {print x}')"
    # XXX: Set a manual swapsize here if the default doesn't fit your use case
    swapsize="$(awk -F"\n" '/MemTotal/ {split($0, b, " "); print b[2] }' /proc/meminfo)";
    target="/mnt"
    timezone="America/Chicago"
    keymap="us"
    libclocale="en_US.UTF-8"
    username="voidlinux"
    end_action="shutdown"
    end_script="/bin/true"

    XBPS_ARCH="$(xbps-uhelper arch)"
    case $XBPS_ARCH in
        *-musl)
            xbpsrepository="https://repo-default.voidlinux.org/current/musl"
            ;;
        *)
            xbpsrepository="https://repo-default.voidlinux.org/current"
            ;;
    esac

    # --------------- Pull config URL out of kernel cmdline -------------------------
    if getargbool 0 autourl ; then
        xbps-uhelper fetch "$(getarg autourl)>/etc/autoinstall.cfg"

    else
        mv /etc/autoinstall.default /etc/autoinstall.cfg
    fi

    # Read in the resulting config file which we got via some method
    if [ -f /etc/autoinstall.cfg ] ; then
        VAI_info_msg "Reading configuration file"
        . ./etc/autoinstall.cfg
    fi

    # Bail out if we didn't get a usable disk
    if [ -z "$disk" ] ; then
        die "No valid disk!"
    fi
}

VAI_main() {
    CURRENT_STEP=0
    STEP_COUNT=16

    VAI_welcome

    VAI_print_step "Bring up the network"
    VAI_get_address

    VAI_print_step "Configuring installer"
    VAI_configure_autoinstall

    VAI_print_step "Configuring disk using scheme 'Atomic'"
    VAI_partition_disk
    VAI_format_disk

    VAI_print_step "Mounting the target filesystems"
    VAI_mount_target

    VAI_print_step "Installing XBPS keys"
    VAI_install_xbps_keys

    VAI_print_step "Installing the base system"
    VAI_install_base_system

    VAI_print_step "Granting sudo to default user"
    VAI_configure_sudo

    VAI_print_step "Setting hostname"
    VAI_configure_hostname

    VAI_print_step "Configure rc.conf"
    VAI_configure_rc_conf

    VAI_print_step "Preparing the chroot"
    VAI_prepare_chroot

    VAI_print_step "Fix ownership of /"
    VAI_correct_root_permissions

    VAI_print_step "Adding default user"
    VAI_add_user

    VAI_print_step "Configuring GRUB"
    VAI_configure_grub

    VAI_print_step "Configuring /etc/fstab"
    VAI_configure_fstab

    VAI_print_step "Configuring libc-locales"
    VAI_configure_locale

    VAI_print_step "Performing end-action"
    VAI_end_action
}

# If we are using the autoinstaller, launch it
if getargbool 0 auto  ; then
    VAI_main
fi

# Very important to release this before returning to dracut code
set +e
