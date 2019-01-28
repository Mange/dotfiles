.DEFAULT_GOAL := default
.PHONY: default base

images := anne-pro-base.png $(patsubst %.yml,%.png,$(wildcard *.yml))

%.png: %.json generate_screenshot.rb
	./generate_screenshot.rb $< $@

%.json: %.yml generate_overlay.rb anne-pro-base.json
	./generate_overlay.rb anne-pro-base.json $< > $@

super_overlay.yml: i3_bindings.rb ../config/i3/config
	@# Redirection will always output a file, even if script crashes. Redirect to
	@# a temp file and rename it if command succeeded.
	./i3_bindings.rb ../config/i3/config > super_overlay.yml.tmp
	mv super_overlay.yml.tmp super_overlay.yml

base: anne-pro-base.png

default: $(images)
