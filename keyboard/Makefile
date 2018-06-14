.DEFAULT_GOAL := default
.PHONY: default base

images := anne-pro-base.png $(patsubst %.yml,%.png,$(wildcard *.yml))

%.png: %.json generate_screenshot.rb
	./generate_screenshot.rb $< $@

%.json: %.yml generate_overlay.rb anne-pro-base.json
	./generate_overlay.rb anne-pro-base.json $< > $@

base: anne-pro-base.png

default: $(images)
