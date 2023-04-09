#!/bin/bash

set -e

usage() {
	echo "release.sh start [-l LIVE_ARCHS] [-f LIVE_VARIANTS] [-a ROOTFS_ARCHS]"
	echo "    [-p PLATFORMS] [-i SBC_IMGS] [-d DATE] [-r REPOSITORY] -- [gh args...]"
	echo "release.sh dl [gh args...]"
	echo "release.sh sign DATE SHASUMFILE"
	exit 1
}

check_programs() {
	for prog; do
		if ! type $prog &>/dev/null; then
			echo "missing program: $prog"
			exit 1
		fi
	done
}

start_build() {
	check_programs gh
	ARGS=()
	while getopts "a:d:f:i:l:p:r:" opt; do
		case $opt in
			a) ARGS+=(-f rootfs="$OPTARG") ;;
			d) ARGS+=(-f datecode="$OPTARG") ;;
			f) ARGS+=(-f live_flavors="$OPTARG") ;;
			i) ARGS+=(-f sbc_imgs="$OPTARG") ;;
			l) ARGS+=(-f live_archs="$OPTARG") ;;
			p) ARGS+=(-f platformfs="$OPTARG") ;;
			r) ARGS+=(-f mirror="$OPTARG") ;;
			?) usage;;
		esac
	done
	shift $((OPTIND - 1))
	gh workflow run gen-images.yml "${ARGS[@]}" "$@"
}

# this assumes that the latest successful build is the one to download
# wish it could be better but alas:
# https://github.com/cli/cli/issues/4001
download_build() {
	check_programs gh
	run="$(gh run list -s success -w gen-images.yml --json databaseId -q '.[].databaseId' "$@" | sort -r | head -1)"
	echo "Downloading artifacts from run ${run} [this may take a while] ..."
	gh run download "$run" -p 'void-live*' "$@"
	echo "Done."
}

sign_build() {
	check_programs pwgen signify
	DATE="$1"
	SUMFILE="$2"
	mkdir -p release
	KEYFILE="release/void-release-$DATE.key"
	pwgen -cny 25 1 > "$KEYFILE"
	signify -G -p "${KEYFILE//key/pub}" -s "${KEYFILE//key/sec}" -c "This key is only valid for images with date $DATE."
	signify -S -e -s "${KEYFILE//key/sec}" -m "$SUMFILE" -x "${SUMFILE//txt/sig}"
}

case "$1" in
	st*) shift; start_build "$@" ;;
	d*) shift; download_build "$@" ;;
	si*) shift; sign_build "$@" ;;
	*) usage ;;
esac
