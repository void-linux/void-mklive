#!/bin/sh

# This contains the COMPLETE list of binaries that this script needs
# to function.  The only exception is the QEMU binary since it is not
# known in advance which one wil be required.
readonly LIBTOOLS="cp echo cat printf which mountpoint mount umount modprobe"
readonly HOSTARCH=$(xbps-uhelper arch)

is_target_native() {
    # Because checking whether the target is runnable is ugly, stuff
    # it into a single function. That makes it easy to check anywhere.
    local target_arch

    target_arch="$1"
    # this will cover most
    if [ "${target_arch%-musl}" = "${HOSTARCH%-musl}" ]; then
        return 0
    fi

    case "$HOSTARCH" in
        # ppc64le has no 32-bit variant, only runs its own stuff
        ppc64le*) return 1 ;;
        # x86_64 also runs i686
        x86_64*) test -z "${target_arch##*86*}" ;;
        # aarch64 also runs armv*
        aarch64*) test -z "${target_arch##armv*}" ;;
        # bigendian ppc64 also runs ppc
        ppc64*) test "${target_arch%-musl}" = "ppc" ;;
        # anything else is just their own
        *) return 1 ;;
    esac

    return $?
}

version() (
    set +u
    [ -n "$PROGNAME" ] && printf "%s " "$PROGNAME"
    echo "$(cat ./version) ${MKLIVE_REV:-"$(git -c safe.directory="$(pwd)" rev-parse --short HEAD 2> /dev/null)"}"
)

info_msg() {
    # This function handles the printing that is bold within all
    # scripts.  This is a convenience function so that the rather ugly
    # looking ASCII escape codes live in only one place.
    printf "\033[1m%s\n\033[m" "$@"
}

die() {
    # This function is registered in all the scripts to make sure that
    # the important mounts get cleaned up and the $ROOTFS location is
    # removed.
    printf "FATAL: %s\n" "$@"
    umount_pseudofs
    [ -d "$ROOTFS" ] && rm -rf "$ROOTFS"
    exit 1
}

check_tools() {
    # All scripts within mklive declare the tools they will use in a
    # variable called "REQTOOLS".  This function checks that these
    # tools are available and prints out the path to each tool that
    # will be used.  This can be useful to figure out what is broken
    # if a different version of something is used than was expected.
    for tool in $LIBTOOLS $REQTOOLS ; do
        if ! which "$tool" > /dev/null ; then
            die "Required tool $tool is not available on this system!"
        fi
    done

    info_msg "The following tools will be used:"
    for tool in $LIBTOOLS $REQTOOLS ; do
        which "$tool"
    done
}

mount_pseudofs() {
    # This function ensures that the psuedofs mountpoints are present
    # in the chroot.  Strictly they are not necessary to have for many
    # commands, but bind-mounts are cheap and it isn't too bad to just
    # mount them all the time.
    for f in dev proc sys; do
        # In a naked chroot there is nothing to bind the mounts to, so
        # we need to create directories for these first.
        [ ! -d "$ROOTFS/$f" ] && mkdir -p "$ROOTFS/$f"
        if ! mountpoint -q "$ROOTFS/$f" ; then
            # It is VERY important that this only happen if the
            # pseudofs isn't already mounted.  If it already is then
            # this is virtually impossible to troubleshoot because it
            # looks like the subsequent umount just isn't working.
            mount -r --rbind /$f "$ROOTFS/$f" --make-rslave
        fi
    done
    if ! mountpoint -q "$ROOTFS/tmp" ; then
        mkdir -p "$ROOTFS/tmp"
        mount -o mode=0755,nosuid,nodev -t tmpfs tmpfs "$ROOTFS/tmp"
    fi
}

umount_pseudofs() {
    # This function cleans up the mounts in the chroot.  Failure to
    # clean up these mounts will prevent the tmpdir from being
    # deletable instead throwing the error "Device or Resource Busy".
    # The '-f' option is passed to umount to account for the
    # contingency where the psuedofs mounts are not present.
    if [ -d "${ROOTFS}" ]; then
        for f in dev proc sys; do
            umount -R -f "$ROOTFS/$f" >/dev/null 2>&1
        done
    fi
    umount -f "$ROOTFS/tmp" >/dev/null 2>&1
}

run_cmd_target() {
    info_msg "Running $* for target $XBPS_TARGET_ARCH ..."
    if is_target_native "$XBPS_TARGET_ARCH"; then
        # This is being run on the same architecture as the host,
        # therefore we should set XBPS_ARCH.
        if ! eval XBPS_ARCH="$XBPS_TARGET_ARCH" "$@" ; then
            die "Could not run command $*"
        fi
    else
        # This is being run on a foriegn arch, therefore we should set
        # XBPS_TARGET_ARCH.  In this case XBPS will not attempt
        # certain actions and will require reconfiguration later.
        if ! eval XBPS_TARGET_ARCH="$XBPS_TARGET_ARCH" "$@" ; then
            die "Could not run command $*"
        fi
    fi
}

run_cmd() {
    # This is a general purpose function to run commands that a user
    # may wish to see.  For example its useful to see the tar/xz
    # pipeline to not need to delve into the scripts to see what
    # options its set up with.
    info_msg "Running $*"
    eval "$@"
}

run_cmd_chroot() {
    # General purpose chroot function which makes sure the chroot is
    # prepared.  This function takes 2 arguments, the location to
    # chroot to and the command to run.

    # This is an idempotent function, it is safe to call every time
    # before entering the chroot.  This has the advantage of making
    # execution in the chroot appear as though it "Just Works(tm)".
    register_binfmt

    # Before we step into the chroot we need to make sure the
    # pseudo-filesystems are ready to go.  Not all commands will need
    # this, but its still a good idea to call it here anyway.
    mount_pseudofs

    # With assurance that things will run now we can jump into the
    # chroot and run stuff!
    chroot "$1" sh -c "$2"
}

cleanup_chroot() {
    # This function cleans up the chroot shims that are used by QEMU
    # to allow builds on alien platforms.  It takes no arguments but
    # expects the global $ROOTFS variable to be set.

    # Un-Mount the pseudofs mounts if they were mounted
    umount_pseudofs
}

register_binfmt() {
    # This function sets up everything that is needed to be able to
    # chroot into a ROOTFS and be able to run commands there.  This
    # really matters on platforms where the host architecture is
    # different from the target, and you wouldn't be able to run
    # things like xbps-reconfigure -a.  This function is idempotent
    # (You can run it multiple times without modifying state).  This
    # function takes no arguments, but does expect the global variable
    # $XBPS_TARGET_ARCH to be set.

    # This select sets up the "magic" bytes in /proc that let the
    # kernel select an alternate interpreter.  More values for this
    # map can be obtained from here:
    # https://github.com/qemu/qemu/blob/master/scripts/qemu-binfmt-conf.sh

    # If the XBPS_TARGET_ARCH is unset but the PLATFORM is known, it
    # may be possible to set the architecture from the static
    # platforms map.
    if [ -z "$XBPS_TARGET_ARCH" ] && [ ! -z "$PLATFORM" ] ; then
        set_target_arch_from_platform
    fi

    # In the special case where the build is native we can return
    # without doing anything else
    # This is only a basic check for identical archs, with more careful
    # checks below for cases like ppc64 -> ppc and x86_64 -> i686.
    _hostarch="${HOSTARCH%-musl}"
    _targetarch="${XBPS_TARGET_ARCH%-musl}"
    if [ "$_hostarch" = "$_targetarch" ] ; then
        return
    fi

    case "${_targetarch}" in
        armv*)
            # TODO: detect aarch64 hosts that run 32 bit ARM without qemu (some cannot)
            if ( [ "${_targetarch}" = "armv6l" ] && [ "${_hostarch}" = "armv7l" ] ) ; then
                return
            fi
            if [ "${_targetarch}" = "armv5tel" -a \
                \( "${_hostarch}" = "armv6l" -o "${_hostarch}" = "armv7l" \) ] ; then
                return
            fi
            _cpu=arm
            ;;
        aarch64)
            _cpu=aarch64
            ;;
        ppc64le)
            _cpu=ppc64le
            ;;
        ppc64)
            _cpu=ppc64
            ;;
        ppc)
            if [ "$_hostarch" = "ppc64" ] ; then
                return
            fi
            _cpu=ppc
            ;;
        mipsel)
            if [ "$_hostarch" = "mips64el" ] ; then
                return
            fi
            _cpu=mipsel
            ;;
        x86_64)
            _cpu=x86_64
            ;;
        i686)
            if [ "$_hostarch" = "x86_64" ] ; then
                return
            fi
            _cpu=i386
            ;;
        riscv64)
            _cpu=riscv64
            ;;
        *)
            die "Unknown target architecture!"
            ;;
    esac

    # For builds that do not match the host architecture, the correct
    # qemu binary will be required.
    QEMU_BIN="qemu-${_cpu}"
    if ! $QEMU_BIN -version >/dev/null 2>&1; then
        die "$QEMU_BIN binary is missing in your system, exiting."
    fi

    # In order to use the binfmt system the binfmt_misc mountpoint
    # must exist inside of proc
    if ! mountpoint -q /proc/sys/fs/binfmt_misc ; then
        modprobe -q binfmt_misc
        mount -t binfmt_misc binfmt_misc /proc/sys/fs/binfmt_misc 2>/dev/null
    fi

    # Only register if the map is incomplete
    if [ ! -f /proc/sys/fs/binfmt_misc/qemu-$_cpu ] ; then
        if ! command -v update-binfmts >/dev/null 2>&1; then
            die "could not add binfmt: update-binfmts binary is missing in your system"
        fi
        update-binfmts --import "qemu-$_cpu"
    fi
}

set_target_arch_from_platform() {
    # This function maintains a lookup from platform to target
    # architecture.  This is required for scripts that need to know
    # the target architecture, but don't necessarily need to know it
    # internally (i.e. only run_cmd_chroot).
    case "$PLATFORM" in
        rpi-aarch64*) XBPS_TARGET_ARCH="aarch64";;
        rpi-armv7l*) XBPS_TARGET_ARCH="armv7l";;
        rpi-armv6l*) XBPS_TARGET_ARCH="armv6l";;
        i686*) XBPS_TARGET_ARCH="i686";;
        x86_64*) XBPS_TARGET_ARCH="x86_64";;
        GCP*) XBPS_TARGET_ARCH="x86_64";;
        pinebookpro*) XBPS_TARGET_ARCH="aarch64";;
        pinephone*) XBPS_TARGET_ARCH="aarch64";;
        rock64*) XBPS_TARGET_ARCH="aarch64";;
        rockpro64*) XBPS_TARGET_ARCH="aarch64";;
        asahi*) XBPS_TARGET_ARCH="aarch64";;
        *) die "$PROGNAME: Unable to compute target architecture from platform";;
    esac

    if [ -z "${PLATFORM##*-musl}" ] ; then
        XBPS_TARGET_ARCH="${XBPS_TARGET_ARCH}-musl"
    fi
}

set_dracut_args_from_platform() {
    # In rare cases it is necessary to set platform specific dracut
    # args.  This is mostly the case on ARM platforms.
    case "$PLATFORM" in
        *) ;;
    esac
}

set_cachedir() {
    # The package artifacts are cacheable, but they need to be isolated
    # from the host cache.
    : "${XBPS_CACHEDIR:=--cachedir=$PWD/xbps-cache/${XBPS_TARGET_ARCH}}"
}

rk33xx_flash_uboot() {
    local dir="$1"
    local dev="$2"
    dd if="${dir}/idbloader.img" of="${dev}" seek=64 conv=notrunc,fsync >/dev/null 2>&1
    dd if="${dir}/u-boot.itb" of="${dev}" seek=16384 conv=notrunc,fsync >/dev/null 2>&1
}

# These should all resolve even if they won't have the appropriate
# repodata files for the selected architecture.
: "${XBPS_REPOSITORY:=--repository=https://repo-default.voidlinux.org/current \
                      --repository=https://repo-default.voidlinux.org/current/musl \
                      --repository=https://repo-default.voidlinux.org/current/aarch64}"

# This library is the authoritative source of the platform map,
# because of this we may need to get this information from the command
# line.  This select allows us to get that information out.  This
# fails silently if the toolname isn't known since this script is
# sourced.
case "${1:-}" in
    platform2arch)
        PLATFORM=$2
        set_target_arch_from_platform
        echo "$XBPS_TARGET_ARCH"
        ;;
esac
