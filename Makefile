GITVER := $(shell git rev-parse --short HEAD)
VERSION = 0.22
SHIN    += $(shell find -type f -name '*.sh.in')
SCRIPTS += $(SHIN:.sh.in=.sh)
DATE=$(shell date "+%Y%m%d")

T_PLATFORMS=rpi{,2,3}{,-musl} beaglebone{,-musl} cubieboard2{,-musl} odroid-c2{,-musl} usbarmory{,-musl} GCP{,-musl}
T_ARCHS=i686 x86_64{,-musl} armv{6,7}l{,-musl} aarch64{,-musl}

T_SBC_IMGS=rpi{,2,3}{,-musl} beaglebone{,-musl} cubieboard2{,-musl} odroid-c2{,-musl} usbarmory{,-musl}
T_CLOUD_IMGS=GCP{,-musl}

ARCHS=$(shell echo $(T_ARCHS))
PLATFORMS=$(shell echo $(T_PLATFORMS))
SBC_IMGS=$(shell echo $(T_SBC_IMGS))
CLOUD_IMGS=$(shell echo $(T_CLOUD_IMGS))

ALL_ROOTFS=$(foreach arch,$(ARCHS),void-$(arch)-ROOTFS-$(DATE).tar.xz)
ALL_PLATFORMFS=$(foreach platform,$(PLATFORMS),void-$(platform)-PLATFORMFS-$(DATE).tar.xz)
ALL_SBC_IMAGES=$(foreach platform,$(SBC_IMGS),void-$(platform)-$(DATE).img.xz)
ALL_CLOUD_IMAGES=$(foreach cloud,$(CLOUD_IMGS),void-$(cloud)-$(DATE).tar.gz)

SUDO := sudo

XBPS_REPOSITORY := -r https://lug.utdallas.edu/mirror/void/current -r https://lug.utdallas.edu/mirror/void/current/musl -r https://lug.utdallas.edu/mirror/void/current/aarch64

%.sh: %.sh.in
	 sed -e "s|@@MKLIVE_VERSION@@|$(VERSION) $(GITVER)|g" $^ > $@
	 chmod +x $@

all: $(SCRIPTS)

clean:
	rm -v *.sh

distdir-$(DATE):
	mkdir -p distdir-$(DATE)

dist: distdir-$(DATE)
	mv void*$(DATE)* distdir-$(DATE)/

rootfs-all: $(ALL_ROOTFS)

rootfs-all-print:
	echo $(ALL_ROOTFS)

void-%-ROOTFS-$(DATE).tar.xz: $(SCRIPTS)
	$(SUDO) ./mkrootfs.sh $(XBPS_REPOSITORY) $*

void-%-PLATFORMFS-$(DATE).tar.xz: $(SCRIPTS)
	$(SUDO) ./mkplatformfs.sh $(XBPS_REPOSITORY) $* void-$(shell ./lib.sh platform2arch $*)-ROOTFS-$(DATE).tar.xz

platformfs-all: rootfs-all $(ALL_PLATFORMFS)

platformfs-all-print:
	@echo $(ALL_PLATFORMFS) | sed "s: :\n:g"

images-all: platformfs-all images-all-sbc images-all-cloud

images-all-sbc: $(ALL_SBC_IMAGES)

images-all-cloud: $(ALL_CLOUD_IMAGES)

images-all-print:
	@echo $(ALL_SBC_IMAGES) $(ALL_CLOUD_IMAGES)

void-%-$(DATE).img.xz:
	$(SUDO) ./mkimage.sh void-$*-PLATFORMFS-$(DATE).tar.xz

# The GCP images are special for $reasons
void-GCP-$(DATE).tar.gz:
	$(SUDO) ./mkimage.sh void-GCP-PLATFORMFS-$(DATE).tar.xz

void-GCP-musl-$(DATE).tar.gz:
	$(SUDO) ./mkimage.sh void-GCP-musl-PLATFORMFS-$(DATE).tar.xz



.PHONY: clean dist rootfs-all-print platformfs-all-print
