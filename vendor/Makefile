.PHONY: all update pull playerctl-install i3-gaps-install i3blocks-gaps-install lastpass-cli-install
.DEFAULT_GOAL = all

FIND_SOURCE_FILES = -type f -not -path '*/\.*' -regex '.*\.\(c\|cpp\|h\|hpp\|sh\|in\|am\)'

all: i3-gaps-install i3blocks-gaps-install playerctl-install lastpass-cli-install

update: | pull all

pull: i3-gaps i3blocks-gaps playerctl lastpass-cli
	cd i3-gaps && git pull --rebase
	cd i3blocks-gaps && git pull --rebase
	cd playerctl && git pull --rebase
	cd lastpass-cli && git reset --hard && git pull --rebase

playerctl-install: /usr/bin/playerctl
i3-gaps-install: /usr/bin/i3
i3blocks-gaps-install: /usr/bin/i3blocks
lastpass-cli-install: /usr/local/bin/lpass

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

i3blocks-gaps:
	git clone https://github.com/Airblader/i3blocks-gaps

i3blocks-gaps/i3blocks: $(shell find i3blocks-gaps $(FIND_SOURCE_FILES)) | i3blocks-gaps
	cd i3blocks-gaps && $(MAKE) all

/usr/bin/i3blocks: i3blocks-gaps/i3blocks
	cd i3blocks-gaps && sudo $(MAKE) install PREFIX=/usr

lastpass-cli:
	git clone https://github.com/lastpass/lastpass-cli

lastpass-cli/lpass: $(shell find lastpass-cli $(FIND_SOURCE_FILES)) | lastpass-cli
	cd lastpass-cli && cmake . && $(MAKE)

/usr/local/bin/lpass: lastpass-cli/lpass
	sudo $(MAKE) -C lastpass-cli install install-doc
