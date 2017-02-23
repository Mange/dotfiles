.PHONY: linux playerctl-install i3-gaps-install
.DEFAULT_GOAL = linux

linux: i3-gaps-install playerctl-install

playerctl-install: /usr/bin/playerctl
i3-gaps-install: /usr/bin/i3

playerctl:
	git clone https://github.com/acrisci/playerctl

playerctl/configure: | playerctl
	cd playerctl && ./autogen.sh --prefix=/usr

playerctl/playerctl/playerctl: playerctl/configure
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

i3-gaps/build/i3: i3-gaps/build/Makefile
	cd i3-gaps/build && make

/usr/bin/i3: i3-gaps/build/i3
	cd i3-gaps/build && sudo make install
