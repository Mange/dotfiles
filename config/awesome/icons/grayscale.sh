#!/bin/bash

if ! [[ -f "$1" ]]; then
  echo "Specify a file to convert!" >&2
  exit 1
fi

output="${2:-${1/\.png/-gray\.png}}"

if [[ "$1" = "$output" ]]; then
  echo "Input and output is the same!" >&2
  exit 1
fi

convert "$1" -fx '(r+g+b)/3' -colorspace Gray "$output"
