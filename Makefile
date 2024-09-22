# Directory variables.
SRCROOT=$(PWD)
OUTDIR=$(SRCROOT)/out
SRCDATADIR=$(SRCROOT)/data
DESTDIR=
PREFIX=/usr/local
SYSCONFDIR=/etc
BINDIR=$(DESTDIR)$(PREFIX)/bin
SYSTEMDUNITDIR=$(DESTDIR)$(SYSCONFDIR)/systemd/system
TMPFILESDIR=$(DESTDIR)$(SYSCONFDIR)/tmpfiles.d
SYSUSERSDIR=$(DESTDIR)$(SYSCONFDIR)/sysusers.d

# File wildcards.
SYSTEMDUNITS=*.service
TMPFILESDCONFIGS=*.tmpfiles
SYSUSERSDCONFIGS=*.sysusers

# Program suffix.
PROGPREFIX=aosc-portal-

# Command variables.
INSTALL_PROG=install -Dvm755
INSTALL_FILE=install -Dvm644

.PHONY: paste-server make-news-index

all: paste-server make-news-index

paste-server:
	mkdir -pv $(OUTDIR)
	cd $(SRCROOT)/paste-server && \
		go build -o $(OUTDIR)/$(PROGPREFIX)paste-server

make-news-index:
	mkdir -pv $(OUTDIR)
	cd $(SRCROOT)/make-news-index && \
		go build -o $(OUTDIR)/$(PROGPREFIX)make-news-index

install: install-paste-server install-make-news-index install-systemd

install-paste-server:
	$(INSTALL_PROG) $(OUTDIR)/$(PROGPREFIX)paste-server \
		$(LIBEXECDIR)/$(PROGPREFIX)paste-server/$(PROGPREFIX)paste-server
	$(INSTALL_FILE) $(SRCDATADIR)/paste-server-config.yaml \
		$(LIBEXECDIR)/$(PROGPREFIX)paste-server/config.yaml

install-make-news-index:
	$(INSTALL_PROG) $(OUTDIR)/$(PROGPREFIX)make-news-index \
		$(BINDIR)/$(PROGPREFIX)make-news-index

install-systemd:
	# Installing systemd files.
	cd $(SRCDATADIR) && \
	for i in $(SYSTEMDUNITS); do \
		$(INSTALL_FILE) $$i \
			$(SYSTEMDUNITDIR)/$(PROGPREFIX)$$i; \
		sed \
			-e "s|@BINDIR@|$(BINDIR)|g" \
			-e "s|@PROGPREFIX@|$(PROGPREFIX)|g" \
			-i $(SYSTEMDUNITDIR)/$(PROGPREFIX)$$i; \
	done && \
	for i in $(TMPFILESDCONFIGS); do \
		$(INSTALL_FILE) $$i \
			$(TMPFILESDIR)/$(PROGPREFIX)$$i; \
		sed \
			-e "s|@PROGPREFIX@|$(PROGPREFIX)|g" \
			-i $(TMPFILESDIR)/$(PROGPREFIX)$$i; \
	done && \
	for i in $(SYSUSERSDCONFIGS); do \
		$(INSTALL_FILE) $$i \
                        $(SYSUSERSDIR)/$(PROGPREFIX)$$i; \
		sed \
			-e "s|@PROGPREFIX@|$(PROGPREFIX)|g" \
			-i $(SYSUSERSDIR)/$(PROGPREFIX)$$i; \
	done

clean:
	rm -rfv \
		$(OUTDIR) \
		$(SRCDATADIR)/*.service
