# The Void Linux image/live/rootfs maker and installer

This repository contains utilities for Void Linux:

 * installer (The Void Linux el-cheapo installer for x86)
 * mklive    (The Void Linux live image maker for x86)

 * mkimage   (The Void Linux image maker for ARM platforms)
 * mkplatformfs (The Void Linux filesystem tool to produce a rootfs for a particular platform)
 * mkrootfs  (The Void Linux rootfs maker for ARM platforms)
 * mknet (Script to generate netboot tarballs for Void)

## Dependencies
 * Compression type for the initramfs image
   * liblz4 (for lz4, xz) (default)
 * xbps>=0.45
 * qemu-user-static binaries (for mkrootfs)
 * bash

## Usage

See the usage output:

    $ ./mklive.sh -h
    $ ./mkrootfs.sh -h
    $ ./mkimage.sh -h

### Examples

Build a native live image keyboard set to 'fr':

    # ./mklive.sh -k fr

Build an i686 (on x86\_64) live image with some additional packages:

    # ./mklive.sh -a i686 -p 'vim rtorrent'

Build an x86\_64 musl live image with packages stored in a local repository:

    # ./mklive.sh -a x86_64-musl -r /path/to/host/binpkgs

See the usage output for more information :-)

## Kernel Command-line Parameters

`void-mklive`-based live images support several kernel command-line arguments
that can change the behavior of the live system:

- `live.autologin` will skip the initial login screen on `tty1`.
- `live.user` will change the username of the non-root user from the default `anon`. The password remains `voidlinux`.
- `live.shell` sets the default shell for the non-root user in the live environment.
- `live.accessibility` enables accessibility features like the console screenreader `espeakup` in the live environment.
- `console` can be set to `ttyS0`, `hvc0`, or `hvsi0` to enable `agetty` on that serial console.
- `locale.LANG` will set the `LANG` environment variable. Defaults to `en_US.UTF-8`.
- `vconsole.keymap` will set the console keymap. Defaults to `us`.

### Examples:

- `live.autologin live.user=foo live.shell=/bin/bash` would create the user `foo` with the default shell `/bin/bash` on boot, and log them in automatically on `tty1`
- `live.shell=/bin/bash` would set the default shell for the `anon` user to `/bin/bash`
- `console=ttyS0 vconsole.keymap=cf` would enable `ttyS0` and set the keymap in the console to `cf`
- `locale.LANG=fr_CA.UTF-8` would set the live system's language to `fr_CA.UTF-8`
