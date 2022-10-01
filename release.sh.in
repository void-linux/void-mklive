#!/bin/bash

XBPS_REPOSITORY="-r /hostdir/binpkgs -r /hostdir/binpkgs/musl -r /hostdir/binpkgs/aarch64"
DATECODE=$(date "+%Y%m%d")

make

ARCHS="$(echo x86_64{,-musl} i686 armv{6,7}l{,-musl} aarch64{,-musl})"
PLATFORMS="$(echo rpi-{armv{6,7}l,aarch64}{,-musl})"
SBC_IMGS="$(echo rpi-{armv{6,7}l,aarch64}{,-musl})"

make rootfs-all ARCHS="$ARCHS" XBPS_REPOSITORY="$XBPS_REPOSITORY" DATECODE="$DATECODE"
make platformfs-all PLATFORMS="$PLATFORMS" XBPS_REPOSITORY="$XBPS_REPOSITORY" DATECODE="$DATECODE"
make images-all-sbc SBC_IMGS="$SBC_IMGS" XBPS_REPOSITORY="$XBPS_REPOSITORY" DATECODE="$DATECODE"

MKLIVE_REPO=(-r /hostdir/binpkgs -r /hostdir/binpkgs/nonfree -r /hostdir/musl -r /hostdir/binpkgs/musl/nonfree)
./build-x86-images.sh -a i686 -b base "${MKLIVE_REPO[@]}"
./build-x86-images.sh -a i686 -b xfce "${MKLIVE_REPO[@]}"

./build-x86-images.sh -a x86_64 -b base "${MKLIVE_REPO[@]}"
./build-x86-images.sh -a x86_64 -b xfce "${MKLIVE_REPO[@]}"

./build-x86-images.sh -a x86_64-musl -b base "${MKLIVE_REPO[@]}"
./build-x86-images.sh -a x86_64-musl -b xfce "${MKLIVE_REPO[@]}"

mkdir "$DATECODE"
mv "*${DATECODE}*.xz" "$DATECODE/"
mv "*${DATECODE}*.gz" "$DATECODE/"
mv "*${DATECODE}*.iso" "$DATECODE/"

cd "$DATECODE" || exit 1
sha256sum --tag -- * > sha256sums.txt
