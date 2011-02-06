#!/bin/zsh

setopt extendedglob

# Source /etc/profile if /etc/zprofile does not exist
if [ ! -e /etc/zprofile ]; then
    source /etc/profile
fi

for file in ~/.zshrc.d/S*[^~] ; do
     source $file
done

