# Basic Makefile

UUID = arch-update-security-news@slaclau.github.io
BASE_MODULES = extension.js metadata.json LICENCE.txt README.md
EXTRA_MODULES = prefs.js prefs.xml
ICONS = icons
TOLOCALIZE =  extension.js prefs.js
PO_FILES := $(wildcard locale/*/*.po)
MO_FILES := $(PO_FILES:locale/%/arch-update.po=locale/%/LC_MESSAGES/arch-update.mo)

ifeq ($(strip $(DESTDIR)),)
	INSTALLTYPE = local
	INSTALLBASE = $(HOME)/.local/share/gnome-shell/extensions
else
	INSTALLTYPE = system
	SHARE_PREFIX = $(DESTDIR)/usr/share
	INSTALLBASE = $(SHARE_PREFIX)/gnome-shell/extensions
endif
INSTALLNAME = arch-update-security-news@slaclau.github.io

all: extension

clean:
	rm -f ./schemas/gschemas.compiled
	rm -f ./**/*~
	rm -rf ./locale/*/LC_MESSAGES
	rm -f ./locale/arch-update.pot

extension: ./schemas/gschemas.compiled $(MO_FILES)

./schemas/gschemas.compiled: ./schemas/org.gnome.shell.extensions.arch-update-security-news.gschema.xml
	glib-compile-schemas ./schemas/

potfile: ./locale/arch-update.pot

mergepo: potfile
	for l in $(PO_FILES); do \
		msgmerge -U $$l ./locale/arch-update.pot; \
	done;

./locale/arch-update.pot: $(TOLOCALIZE)
	mkdir -p locale
	xgettext -k --keyword=__ --keyword=N__ --add-comments='Translators:' -o locale/arch-update.pot --package-name "Arch Update Security News" $(TOLOCALIZE)

./locale/%/LC_MESSAGES/arch-update.mo: ./locale/%/arch-update.po
	mkdir $(dir $@)
	msgfmt $< -o $@

install: install-local

install-local: _build
	rm -rf $(INSTALLBASE)/$(INSTALLNAME)
	mkdir -p $(INSTALLBASE)/$(INSTALLNAME)
	cp -r ./_build/* $(INSTALLBASE)/$(INSTALLNAME)/
ifeq ($(INSTALLTYPE),system)
	# system-wide settings and locale files
	rm -r $(INSTALLBASE)/$(INSTALLNAME)/schemas
	rm -r $(INSTALLBASE)/$(INSTALLNAME)/locale
	mkdir -p $(SHARE_PREFIX)/glib-2.0/schemas $(SHARE_PREFIX)/locale
	cp -r ./schemas/*gschema.* $(SHARE_PREFIX)/glib-2.0/schemas
	cp -r ./_build/locale/* $(SHARE_PREFIX)/locale
endif
	-rm -fR _build
	echo done

zip-file: _build
	cd _build ; zip -qr "$(UUID).zip" . -x '*.po'
	mv _build/$(UUID).zip ./
	-rm -fR _build

_build: all
	-rm -fR ./_build
	mkdir -p _build
	cp -r $(BASE_MODULES) $(EXTRA_MODULES) $(ICONS) _build
	mkdir -p _build/schemas
	cp schemas/*.xml _build/schemas/
	cp schemas/gschemas.compiled _build/schemas/
	cp -r locale/ _build/locale
