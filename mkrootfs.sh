#!/bin/sh
#-
# Copyright (c) 2013-2015 Juan Romero Pardines.
# Copyright (c) 2017 Google
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#-

readonly PROGNAME=$(basename "$0")
readonly ARCH=$(uname -m)
readonly REQTOOLS="xbps-install xbps-reconfigure tar xz"

# This source pulls in all the functions from lib.sh.  This set of
# functions makes it much easier to work with chroots and abstracts
# away all the problems with running binaries with QEMU.
# shellcheck source=./lib.sh
. ./lib.sh

# Die is a function provided in lib.sh which handles the cleanup of
# the mounts and removal of temporary directories if the running
# program exists unexpectedly.
trap 'die "Interrupted! exiting..."' INT TERM HUP

# Even though we only support really one target for most of these
# architectures this lets us refer to these quickly and easily by
# XBPS_ARCH.  This makes it a lot more obvious what is happening later
# in the script, and it makes it easier to consume the contents of
# these down the road in later scripts.
usage() {
    cat <<-EOH
	Usage: $PROGNAME [options] <arch>

	Generate a Void Linux ROOTFS tarball for the specified architecture.

	Supported architectures:
	 i686, i686-musl, x86_64, x86_64-musl,
	 armv5tel, armv5tel-musl, armv6l, armv6l-musl, armv7l, armv7l-musl
	 aarch64, aarch64-musl,
	 mipsel, mipsel-musl,
	 ppc, ppc-musl, ppc64le, ppc64le-musl, ppc64, ppc64-musl
	 riscv64, riscv64-musl
	
	OPTIONS
	 -b <system-pkg>  Set an alternative base-system package (default: base-container-full)
	 -c <cachedir>    Set XBPS cache directory (default: ./xbps-cachedir-<arch>)
	 -C <file>        Full path to the XBPS configuration file
	 -r <repo>        Use this XBPS repository. May be specified multiple times
	 -o <file>        Filename to write the ROOTFS to (default: automatic)
	 -x <num>         Number of threads to use for image compression (default: dynamic)
	 -h               Show this help and exit
	 -V               Show version and exit
	EOH
}

# ########################################
#      SCRIPT EXECUTION STARTS HERE
# ########################################

# Set the default system package.
SYSPKG="base-container-full"

# Boilerplate option parsing.  This script supports the bare minimum
# needed to build an image.
while getopts "b:C:c:hr:x:o:V" opt; do
    case $opt in
        b) SYSPKG="$OPTARG";;
        C) XBPS_CONFFILE="-C $OPTARG";;
        c) XBPS_CACHEDIR="--cachedir=$OPTARG";;
        r) XBPS_REPOSITORY="$XBPS_REPOSITORY --repository=$OPTARG";;
        x) COMPRESSOR_THREADS="$OPTARG" ;;
        o) FILENAME="$OPTARG" ;;
        V) version; exit 0;;
        h) usage; exit 0;;
        *) usage >&2; exit 1;;
    esac
done
shift $((OPTIND - 1))
XBPS_TARGET_ARCH="$1"

if [ -z "$XBPS_TARGET_ARCH" ]; then
	usage >&2
	exit 1
fi

# Set the XBPS cache
set_cachedir

# This is an aweful hack since the script isn't using privesc
# mechanisms selectively.  This is a TODO item.
if [ "$(id -u)" -ne 0 ]; then
    die "need root perms to continue, exiting."
fi

# Before going any further, check that the tools that are needed are
# present.  If we delayed this we could check for the QEMU binary, but
# its a reasonable tradeoff to just bail out now.
check_tools

# If the arch wasn't set let's bail out now, nothing else in this
# script will work without knowing what we're trying to build for.
if [ -z "$XBPS_TARGET_ARCH" ]; then
    echo "$PROGNAME: arch was not set!"
    usage >&2; exit 1
fi

# We need to operate on a tempdir, if this fails to create, it is
# absolutely crucial to bail out so that we don't hose the system that
# is running the script.
ROOTFS=$(mktemp -d) || die "failed to create tempdir, exiting..."

# This maintains the chain of trust, the keys in the repo are known to
# be good and so we copy those.  Why don't we just use the ones on the
# host system?  That's a good point, but there's no promise that the
# system running the script is Void, or that those keys haven't been
# tampered with.  Its much easier to use these since the will always
# exist.
mkdir -p "$ROOTFS/var/db/xbps/keys"
cp keys/*.plist "$ROOTFS/var/db/xbps/keys"

# This sets up files that are important for XBPS to work on the new
# filesystem.  It does not actually install anything.
run_cmd_target "xbps-install -S $XBPS_CONFFILE $XBPS_CACHEDIR $XBPS_REPOSITORY -r $ROOTFS"

# Later scripts expect the permissions on / to be the canonical 755,
# so we set this here.
chmod 755 "$ROOTFS"

# The binfmt setup and pseudofs mountpoints are needed for the qemu
# support in cases where we are running things that aren't natively
# executable.
register_binfmt
mount_pseudofs

# With everything setup, we can now run the install to load the
# system package into the rootfs.  This will not produce a
# bootable system but will instead produce a base component that can
# be quickly expanded to perform other actions on.
run_cmd_target "xbps-install -SU $XBPS_CONFFILE $XBPS_CACHEDIR $XBPS_REPOSITORY -r $ROOTFS -y $SYSPKG"

# Enable en_US.UTF-8 locale and generate it into the target ROOTFS.
# This is a bit of a hack since some glibc stuff doesn't really work
# correctly without a locale being generated.  While some could argue
# that this is an arbitrary or naive choice to enable the en_US
# locale, most people using Void are able to work with the English
# language at least enough to enable thier preferred locale.  If this
# truly becomes an issue in the future this hack can be revisited.
if [ -e "$ROOTFS/etc/default/libc-locales" ]; then
    LOCALE=en_US.UTF-8
    sed -e "s/\#\(${LOCALE}.*\)/\1/g" -i "$ROOTFS/etc/default/libc-locales"
fi

# The reconfigure step needs to execute code that's been compiled for
# the target architecture.  Since the target isn't garanteed to be the
# same as the host, this needs to be done via qemu.
info_msg "Reconfiguring packages for ${XBPS_TARGET_ARCH} ..."

# This step sets up enough of the base-files that the chroot will work
# and they can be reconfigured natively.  Without this step there
# isn't enough configured for ld to work.  This step runs as the host
# architecture, but we may need to set up XBPS_ARCH for the target
# architecture (but only when compatible).
if is_target_native "$XBPS_TARGET_ARCH"; then
    run_cmd_target "xbps-reconfigure --rootdir $ROOTFS base-files"
else
    run_cmd "xbps-reconfigure --rootdir $ROOTFS base-files"
fi

# Now running as the target system, this step reconfigures the
# base-files completely.  Certain things just won't work in the first
# pass, so this cleans up any issues that linger.
run_cmd_chroot "$ROOTFS" "env -i xbps-reconfigure -f base-files"

# Once base-files is configured and functional its possible to
# configure the rest of the system.
run_cmd_chroot "$ROOTFS" "xbps-reconfigure -a"

# Set the default password.  Previous versions of this script used a
# chroot to do this, but that is unnecessary since chpasswd
# understands how to operate on chroots without actually needing to be
# chrooted.  We also remove the lock file in this step to clean up the
# lock on the passwd database, lest it be left in the system and
# propogated to other points.
info_msg "Setting the default root password ('voidlinux')"
if [ ! -f "$ROOTFS/etc/shadow" ] ; then
    run_cmd_chroot "$ROOTFS" pwconv
fi
echo root:voidlinux | run_cmd_chroot "$ROOTFS" "chpasswd -c SHA512" || die "Could not set default credentials"
rm -f "$ROOTFS/etc/.pwd.lock"

# At this point we're done running things in the chroot and we can
# clean up the shims.  Failure to do this can result in things hanging
# when we try to delete the tmpdir.
cleanup_chroot

# The cache isn't that useful since by the time the ROOTFS will be
# used it is likely to be out of date.  Rather than shipping it around
# only for it to be out of date, we remove it now.
rm -rf "$ROOTFS/var/cache/*" 2>/dev/null

# Finally we can compress the tarball, the name will include the
# architecture and the date on which the tarball was built.
: "${FILENAME:=void-${XBPS_TARGET_ARCH}-ROOTFS-$(date -u '+%Y%m%d').tar.xz}"
run_cmd "tar cp --posix --xattrs --xattrs-include='*' -C $ROOTFS . | xz -T${COMPRESSOR_THREADS:-0} -9 > $FILENAME "

# Now that we have the tarball we don't need the rootfs anymore, so we
# can get rid of it.
rm -rf "$ROOTFS"

# Last thing to do before closing out is to let the user know that
# this succeeded.  This also ensures that there's something visible
# that the user can look for at the end of the script, which can make
# it easier to see what's going on if something above failed.
info_msg "Successfully created $FILENAME ($XBPS_TARGET_ARCH)"
