FONT_DIR = ~/.local/share/fonts
FONTS = FontAwesome.otf PowerlineSymbols.otf devicons.eot
FONT_CONFIG_DIR = ~/.config/fontconfig/conf.d
FONT_CONFIGS = $(FONT_CONFIG_DIR)/10-symbols.conf

.PHONY: update clean install
.DEFAULT_GOAL := install

install: $(FONTS) $(FONT_DIR) $(FONT_CONFIGS) $(addprefix $(FONT_DIR)/,$(FONTS))

clean:
	rm *.otf *.eot

update: clean $(FONTS)

FontAwesome.otf:
	wget https://github.com/FortAwesome/Font-Awesome/raw/master/fonts/FontAwesome.otf

PowerlineSymbols.otf:
	wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf

devicons.eot:
	wget https://github.com/vorillaz/devicons/raw/master/fonts/devicons.eot

$(FONT_DIR):
	mkdir -p $(FONT_DIR)

$(FONT_CONFIG_DIR):
	mkdir -p $(FONT_CONFIG_DIR)

$(FONT_DIR)/%: % $(FONT_DIR)
	cp -v $< $@

$(FONT_CONFIG_DIR)/%: % $(FONT_CONFIG_DIR)
	cp -v $< $@
