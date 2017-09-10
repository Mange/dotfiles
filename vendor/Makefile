.PHONY: all update pull playerctl-install i3-gaps-install i3blocks-gaps-remove lastpass-cli-install rofi-lpass-install
.DEFAULT_GOAL = all

FIND_SOURCE_FILES = -type f -not -path '*/\.*' -regex '.*\.\(c\|cpp\|h\|hpp\|sh\|in\|am\)'

all: i3-gaps-install i3blocks-gaps-remove playerctl-install lastpass-cli-install rofi-lpass-install

update: | pull all

pull: i3-gaps playerctl lastpass-cli rofi-lpass
	cd i3-gaps && git pull --rebase
	cd playerctl && git pull --rebase
	cd lastpass-cli && git reset --hard && git pull --rebase
	cd rofi-lpass && git pull --rebase

$(HOME)/bin:
	mkdir -p $(HOME)/bin

i3blocks-gaps-remove:
	@([ -d ./i3blocks-gaps ] && rm -rf ./i3blocks-gaps) || true

playerctl-install: /usr/bin/playerctl
i3-gaps-install: /usr/bin/i3
lastpass-cli-install: /usr/local/bin/lpass
rofi-lpass-install: $(HOME)/bin/rofi-lpass

playerctl:
	git clone https://github.com/acrisci/playerctl

playerctl/configure: | playerctl
	cd playerctl && ./autogen.sh --prefix=/usr

playerctl/playerctl/playerctl: playerctl/configure $(shell find playerctl $(FIND_SOURCE_FILES))
	$(MAKE) -C playerctl

/usr/bin/playerctl: playerctl/playerctl/playerctl
	sudo $(MAKE) -C playerctl install

i3-gaps:
	git clone https://github.com/Airblader/i3 i3-gaps

# From https://github.com/Airblader/i3/wiki/Compiling-&-Installing
i3-gaps/build/Makefile: | i3-gaps
	cd i3-gaps && autoreconf --force --install
	rm -rf i3-gaps/build/
	mkdir -p i3-gaps/build/
	cd i3-gaps/build && ../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers

i3-gaps/build/i3: i3-gaps/build/Makefile $(shell find i3-gaps $(FIND_SOURCE_FILES))
	cd i3-gaps/build && $(MAKE)

/usr/bin/i3: i3-gaps/build/i3
	cd i3-gaps/build && sudo $(MAKE) install

lastpass-cli:
	git clone https://github.com/lastpass/lastpass-cli

lastpass-cli/lpass: $(shell find lastpass-cli $(FIND_SOURCE_FILES)) | lastpass-cli
	cd lastpass-cli && cmake . && $(MAKE)

/usr/local/bin/lpass: | lastpass-cli/lpass
	sudo $(MAKE) -C lastpass-cli install install-doc

rofi-lpass:
	git clone git@github.com:Mange/rofi-lpass

$(HOME)/bin/rofi-lpass: $(HOME)/bin rofi-lpass
	@ln -sf $(CURDIR)/rofi-lpass/rofi-lpass $(HOME)/bin/rofi-lpass

