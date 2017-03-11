#!/usr/bin/env bash
shopt -s nullglob

eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
export SSH_AUTH_SOCK

[ -d ~/.Xresources.d ] && for f in ~/.Xresources.d/*; do xrdb -merge "-I$HOME" "-I$HOME/.Xresources.d" "$f"; done
[ -f ~/.Xresources.local ] && xrdb -merge "-I$HOME" "-I$HOME/.Xresources.d" ~/.Xresources.local

exec i3
