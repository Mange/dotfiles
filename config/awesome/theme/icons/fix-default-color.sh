#!/bin/sh

find -iname '*.svg' -exec sed -i"" 's/currentColor/#ffffff/g' \{\} \;
