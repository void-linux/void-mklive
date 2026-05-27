FROM ghcr.io/void-linux/void-glibc-full:latest

ARG MIRROR="https://repo-default.voidlinux.org"

RUN xbps-install -SyuR "${MIRROR}/current" xbps && \
    xbps-install -yuR "${MIRROR}/current" && \
    xbps-install -yuR "${MIRROR}/current" \
        bash make git kmod xz lzo \
        qemu-user-static qemu-user-arm qemu-user-aarch64 \
        binfmt-support \
        util-linux outils \
        dosfstools e2fsprogs \
        squashfs-tools xorriso mtools \
        cdrtools syslinux \
        curl wget nano vim

WORKDIR /work

CMD ["/bin/bash"]
