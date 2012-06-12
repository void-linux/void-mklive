VERSION = 0.9.5
SBINDIR ?= /usr/sbin
DRACUTMODDIR ?= /usr/lib/dracut/modules.d/01vmklive

all:
	sed -e "s|@@MKLIVE_VERSION@@|${VERSION}|g" mklive.sh.in > mklive.sh

install: all
	install -d $(DESTDIR)$(SBINDIR)
	install -m755 mklive.sh $(DESTDIR)$(SBINDIR)/void-mklive
	install -d $(DESTDIR)$(DRACUTMODDIR)
	install -m755 dracut/dracut-module.sh \
		$(DESTDIR)$(DRACUTMODDIR)/module-setup.sh
	install -m755 dracut/dracut-vmklive-adduser.sh \
		$(DESTDIR)$(DRACUTMODDIR)/vmklive-adduser.sh

clean:
	-rm -f mklive.sh

.PHONY: all clean install
