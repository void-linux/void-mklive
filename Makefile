VERSION = 0.9.7
SBINDIR ?= /usr/sbin
DRACUTMODDIR ?= /usr/lib/dracut/modules.d/01vmklive

all:
	sed -e "s|@@MKLIVE_VERSION@@|${VERSION}|g" mklive.sh.in > mklive.sh

install: all
	install -d $(DESTDIR)$(SBINDIR)
	install -m755 mklive.sh $(DESTDIR)$(SBINDIR)/void-mklive
	install -d $(DESTDIR)$(DRACUTMODDIR)
	install -m755 dracut/*.sh $(DESTDIR)$(DRACUTMODDIR)

clean:
	-rm -f mklive.sh

dist:
	@echo "Building distribution tarball for tag: v$(VERSION) ..."
	-@git archive --format=tar --prefix=void-mklive-$(VERSION)/ \
		v$(VERSION) | xz -9 > ~/void-mklive-$(VERSION).tar.xz

.PHONY: all clean install dist
