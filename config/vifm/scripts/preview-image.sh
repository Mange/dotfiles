#!/usr/bin/env bash
set -e

action="$1"
x="$2"
y="$3"
width="$4"
height="$5"
filename="$6"
path="$PWD/$filename"

thumbnail_name() {
  local path="/tmp/$1.png"
  mkdir -p "$(dirname "$path")"
  echo "$path"
}

show_image() {
  kitty +icat \
    --transfer-mode=stream \
    --place="${width}x${height}@${x}x${y}" \
    "$1"
}

case $action in
  clear)
    kitty +icat --clear --transfer-mode=stream
    ;;
  draw)
    show_image "$path"
    ;;
  videopreview)
    thumbnail=$(thumbnail_name "$path")
    [[ ! -f "$thumbnail" ]] && ffmpegthumbnailer -i "$path" -o "$thumbnail" -s 0 -q 10
    show_image "$thumbnail"
    ;;
  gifpreview)
    show_image "$path"
    ;;
  epubpreview)
    thumbnail=$(thumbnail_name "$path")
    [[ ! -f "$thumbnail" ]] && epub-thumbnailer "$path" "$thumbnail" 512
    show_image "$thumbnail"
    ;;
  pdfpreview)
    thumbnail=$(thumbnail_name "$path")
    [[ ! -f "$thumbnail" ]] && pdftoppm -png -singlefile "$path" "$thumbnail"
    show_image "$thumbnail"
    ;;
  *)
    echo "Unknown action $action"
    exit 1
esac
