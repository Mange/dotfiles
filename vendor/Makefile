.PHONY: linux
.DEFAULT_GOAL = linux

linux: /usr/bin/playerctl

playerctl:
	git clone https://github.com/acrisci/playerctl

playerctl/configure: | playerctl
	cd playerctl && ./autogen.sh --prefix=/usr

playerctl/playerctl/playerctl: playerctl/configure
	$(MAKE) -C playerctl

/usr/bin/playerctl: playerctl/playerctl/playerctl
	sudo $(MAKE) -C playerctl install
