FONT_DIR = ~/.local/share/fonts
FONTS = FontAwesome.otf PowerlineSymbols.otf devicons.ttf materialdesignicons.ttf
FONT_CONFIG_DIR = ~/.config/fontconfig/conf.d
FONT_CONFIGS := $(wildcard *.conf)

.PHONY: update clean install
.DEFAULT_GOAL := install

install: $(FONTS) $(FONT_DIR) $(addprefix $(FONT_CONFIG_DIR)/,$(FONT_CONFIGS)) $(addprefix $(FONT_DIR)/,$(FONTS))

clean:
	@rm -v *.otf *.eot *.ttf

update: clean $(FONTS)

FontAwesome.otf:
	wget https://github.com/FortAwesome/Font-Awesome/raw/master/fonts/FontAwesome.otf

PowerlineSymbols.otf:
	wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf

devicons.ttf:
	wget https://github.com/vorillaz/devicons/raw/master/fonts/devicons.ttf

materialdesignicons.ttf:
	wget -O materialdesignicons.ttf https://github.com/Templarian/MaterialDesign-Webfont/raw/master/fonts/materialdesignicons-webfont.ttf

$(FONT_DIR):
	mkdir -p $(FONT_DIR)

$(FONT_CONFIG_DIR):
	mkdir -p $(FONT_CONFIG_DIR)

$(FONT_DIR)/%: % $(FONT_DIR)
	@cp -v $< $@

$(FONT_CONFIG_DIR)/%: % $(FONT_CONFIG_DIR)
	@cp -v $< $@
