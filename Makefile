GITVER := $(shell git rev-parse --short HEAD)
VERSION = 0.23
SHIN    += $(shell find -type f -name '*.sh.in')
SCRIPTS += $(SHIN:.sh.in=.sh)
DATECODE=$(shell date "+%Y%m%d")
SHELL=/bin/bash

T_PLATFORMS=rpi-{armv{6,7}l,aarch64}{,-musl} beaglebone{,-musl} cubieboard2{,-musl} odroid-c2{,-musl} GCP{,-musl} pinebookpro{,-musl}
T_ARCHS=i686 x86_64{,-musl} armv{6,7}l{,-musl} aarch64{,-musl}

T_SBC_IMGS=rpi-{armv{6,7}l,aarch64}{,-musl} beaglebone{,-musl} cubieboard2{,-musl} odroid-c2{,-musl} pinebookpro{,-musl}
T_CLOUD_IMGS=GCP{,-musl}

T_PXE_ARCHS=x86_64{,-musl}

T_MASTERDIRS=x86_64{,-musl} i686

ARCHS=$(shell echo $(T_ARCHS))
PLATFORMS=$(shell echo $(T_PLATFORMS))
SBC_IMGS=$(shell echo $(T_SBC_IMGS))
CLOUD_IMGS=$(shell echo $(T_CLOUD_IMGS))
PXE_ARCHS=$(shell echo $(T_PXE_ARCHS))
MASTERDIRS=$(shell echo $(T_MASTERDIRS))

ALL_ROOTFS=$(foreach arch,$(ARCHS),void-$(arch)-ROOTFS-$(DATECODE).tar.xz)
ALL_PLATFORMFS=$(foreach platform,$(PLATFORMS),void-$(platform)-PLATFORMFS-$(DATECODE).tar.xz)
ALL_SBC_IMAGES=$(foreach platform,$(SBC_IMGS),void-$(platform)-$(DATECODE).img.xz)
ALL_CLOUD_IMAGES=$(foreach cloud,$(CLOUD_IMGS),void-$(cloud)-$(DATECODE).tar.gz)
ALL_PXE_ARCHS=$(foreach arch,$(PXE_ARCHS),void-$(arch)-NETBOOT-$(DATECODE).tar.gz)
ALL_MASTERDIRS=$(foreach arch,$(MASTERDIRS), masterdir-$(arch))

SUDO := sudo

XBPS_REPOSITORY := -r https://repo-default.voidlinux.org/current -r https://repo-default.voidlinux.org/current/musl -r https://repo-default.voidlinux.org/current/aarch64
COMPRESSOR_THREADS=2

%.sh: %.sh.in
	 sed -e "s|@@MKLIVE_VERSION@@|$(VERSION) $(GITVER)|g" $^ > $@
	 chmod +x $@

all: $(SCRIPTS)

clean:
	-rm -f *.sh

distdir-$(DATECODE):
	mkdir -p distdir-$(DATECODE)

dist: distdir-$(DATECODE)
	mv void*$(DATECODE)* distdir-$(DATECODE)/

rootfs-all: $(ALL_ROOTFS)

rootfs-all-print:
	@echo $(ALL_ROOTFS) | sed "s: :\n:g"

void-%-ROOTFS-$(DATECODE).tar.xz: $(SCRIPTS)
	$(SUDO) ./mkrootfs.sh $(XBPS_REPOSITORY) -x $(COMPRESSOR_THREADS) $*

platformfs-all: $(ALL_PLATFORMFS)

platformfs-all-print:
	@echo $(ALL_PLATFORMFS) | sed "s: :\n:g"

void-%-PLATFORMFS-$(DATECODE).tar.xz: $(SCRIPTS)
	$(SUDO) ./mkplatformfs.sh $(XBPS_REPOSITORY) -x $(COMPRESSOR_THREADS) $* void-$(shell ./lib.sh platform2arch $*)-ROOTFS-$(DATECODE).tar.xz

images-all: platformfs-all images-all-sbc images-all-cloud

images-all-sbc: $(ALL_SBC_IMAGES)

images-all-sbc-print:
	@echo $(ALL_SBC_IMAGES) | sed "s: :\n:g"

images-all-cloud: $(ALL_CLOUD_IMAGES)

images-all-print:
	@echo $(ALL_SBC_IMAGES) $(ALL_CLOUD_IMAGES) | sed "s: :\n:g"

void-%-$(DATECODE).img.xz: void-%-PLATFORMFS-$(DATECODE).tar.xz
	$(SUDO) ./mkimage.sh -x $(COMPRESSOR_THREADS) void-$*-PLATFORMFS-$(DATECODE).tar.xz

# Some of the images MUST be compressed with gzip rather than xz, this
# rule services those images.
void-%-$(DATECODE).tar.gz: void-%-PLATFORMFS-$(DATECODE).tar.xz
	$(SUDO) ./mkimage.sh -x $(COMPRESSOR_THREADS) void-$*-PLATFORMFS-$(DATECODE).tar.xz

pxe-all: $(ALL_PXE_ARCHS)

pxe-all-print:
	@echo $(ALL_PXE_ARCHS) | sed "s: :\n:g"

void-%-NETBOOT-$(DATECODE).tar.gz: $(SCRIPTS) void-%-ROOTFS-$(DATECODE).tar.xz
	$(SUDO) ./mknet.sh void-$*-ROOTFS-$(DATECODE).tar.xz

masterdir-all-print:
	@echo $(ALL_MASTERDIRS) | sed "s: :\n:g"

masterdir-all: $(ALL_MASTERDIRS)

masterdir-%:
	$(SUDO) docker build --build-arg REPOSITORY=$(XBPS_REPOSITORY) --build-arg ARCH=$* -t voidlinux/masterdir-$*:$(DATECODE) .

.PHONY: clean dist rootfs-all-print rootfs-all platformfs-all-print platformfs-all pxe-all-print pxe-all masterdir-all-print masterdir-all masterdir-push-all
